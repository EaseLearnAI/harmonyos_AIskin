'use strict';
const assert = require('node:assert/strict');
const { test } = require('node:test');
const { extractBusinessComponent, readComponentSource, deferred, nextTurn, typeScriptVersion } = require('./business-component.cjs');
const instantiatePlan = extractBusinessComponent(
    'entry/src/main/ets/components/home/PersonalizedRoutineModal.ets', 'PersonalizedRoutineModal',
    ['aboutToAppear', 'aboutToDisappear', 'generate', 'editAge', 'saveEditedAge',
        'cancelGeneration', 'handleNestedBack', 'close', 'viewSource', 'sourceDetail']
);
const instantiateSkin = extractBusinessComponent(
    'entry/src/main/ets/pages/SkinStatusView.ets', 'SkinStatusView',
    ['aboutToDisappear', 'load', 'remove', 'editContext', 'saveContext',
        'closeContext', 'select', 'handleBack', 'deleteRecord', 'analyze']
);
const instantiateHome = extractBusinessComponent(
    'entry/src/main/ets/pages/HomeView.ets', 'HomeView',
    ['aboutToAppear', 'aboutToDisappear', 'load', 'prepare']
);
console.log(`Business-method adapter: TypeScript ${typeScriptVersion}; services and ArkUI are controlled stubs.`);
async function planFixture(age = 28) {
    const f = { user: { id: 'isolated-user', age }, token: 'isolated-token', saves: [], plans: [], histories: 0 };
    f.save = async (value) => { f.user = { ...f.user, age: value }; return { success: true, user: f.user }; };
    f.plan = async () => ({ success: true, data: { plan: { id: 'fixture-plan' } } });
    f.history = async () => ({ success: true, data: { analyses: [{ _id: 'fixture-source', skinType: { type: '混合性', subtype: '偏干' }, createdAt: '2026-09-15T01:00:00Z' }] } });
    const context = {
        AuthService: { getInstance: () => ({
            getCurrentUser: () => f.user,
            getToken: () => f.token,
            updateAge: async (value) => { f.saves.push(value); return f.save(value); }
        }) },
        PlanApiService: { getInstance: () => ({
            createPlan: async (request) => { f.plans.push(request); return f.plan(request); }
        }) },
        SkinAnalysisApiService: { getInstance: () => ({
            getAnalysisHistory: async () => { f.histories++; return f.history(); }
        }) }
    };
    f.view = instantiatePlan(context);
    f.view.aboutToAppear();
    f.view.selectedConcerns = ['hydration'];
    await nextTurn();
    return f;
}
function skinFixture() {
    const f = { removed: [], patched: [], reads: 0, overlays: [], dialogs: [], backCount: 0 };
    f.records = [{ _id: 'A', context: { condition: 'A original', feelings: ['紧绷'] } }, { _id: 'B', context: { condition: 'B original' } }];
    f.history = async () => ({ success: true, data: { analyses: f.records.slice() } });
    f.deletion = async (id) => { f.records = f.records.filter(r => r._id !== id); return { success: true }; };
    f.patch = async (id, input) => { const updated = { _id: id, context: input }; f.records = f.records.map(r => r._id === id ? updated : r); return { success: true, data: { analysis: updated } }; };
    const context = {
        Scroller: class {},
        AlertDialog: { show: dialog => f.dialogs.push(dialog) },
        SkinAnalysisService: { getInstance: () => ({
            getHistory: () => { f.reads++; return f.history(); },
            deleteAnalysis: id => { f.removed.push(id); return f.deletion(id); }
        }) },
        SkinAnalysisApiService: { getInstance: () => ({
            updateContext: (id, input) => { f.patched.push({ id, input }); return f.patch(id, input); }
        }) }
    };
    f.view = instantiateSkin(context);
    f.view.result = f.records[0];
    f.view.history = f.records.slice();
    f.view.showReport = true;
    f.view.loading = false;
    f.view.onReportVisibility = x => f.overlays.push(x);
    f.view.onBack = () => f.backCount++;
    return f;
}
function homeFixture() {
    const f = { reads: 0, preparationReads: 0, overlays: [], consumed: 0 };
    f.active = async () => ({ success: true, data: { plan: null } });
    const context = {
        PlanApiService: { getInstance: () => ({
            getActivePlan: () => { f.reads++; return f.active(); }
        }) },
        AuthService: { getInstance: () => ({ getCurrentUser: () => ({ id: 'fixture-user' }) }) },
        ProductApiService: { getInstance: () => ({
            getUserProducts: async () => {
                f.preparationReads++;
                return { success: true, data: { products: [{ _id: 'fixture-product' }] } };
            }
        }) },
        SkinAnalysisApiService: { getInstance: () => ({
            getAnalysisHistory: async () => ({ success: true, data: { analyses: [{ _id: 'fixture-source' }] } })
        }) }
    };
    f.view = instantiateHome(context);
    f.view.onOverlay = visible => f.overlays.push(visible);
    return f;
}
test('plan / age: stored age prefill and unchanged-age reuse', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    assert.equal(f.view.userAge, '28');
    await f.view.generate();
    assert.equal(f.saves.length, 0);
    assert.equal(f.plans[0].age, 28);
});
test('plan / age: invalid age blocks save/generation', { timeout: 5000 }, async () => {
    let f;
    for (const value of ['12', '121', '13.5', '']) {
        f = await planFixture();
        f.view.userAge = value;
        await f.view.generate();
        assert.equal(f.saves.length, 0);
        assert.equal(f.plans.length, 0);
    }
});
test('plan / age: save precedes generation and duplicate clicks cannot race', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    const ageGate = deferred();
    f.save = () => ageGate.promise;
    f.view.userAge = '30';
    const first = f.view.generate();
    await nextTurn();
    assert.equal(f.plans.length, 0);
    await f.view.generate();
    assert.equal(f.saves.length, 1);
    f.user = { id: 'isolated-user', age: 30 };
    ageGate.resolve({ success: true, user: f.user });
    await first;
    assert.equal(f.plans.length, 1);
    assert.equal(f.plans[0].age, 30);
    assert.equal(f.view.operationPending, false);
});
test('plan / age: save failure prevents generation and releases state', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    f.view.userAge = '30';
    f.save = async () => ({ success: false, message: 'rejected' });
    await f.view.generate();
    assert.equal(f.plans.length, 0);
    assert.equal(f.view.planError, 'rejected');
    assert.equal(f.view.operationPending, false);
});
test('plan / age: mismatched saved age rejected', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    f.view.userAge = '30';
    f.save = async () => ({ success: true, user: { id: 'isolated-user', age: 29 } });
    await f.view.generate();
    assert.equal(f.plans.length, 0);
    assert.ok(f.view.planError);
});
test('plan / age: cancel while saving suppresses generation and concurrent retry', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    const cancelAge = deferred();
    f.view.userAge = '30';
    f.save = () => cancelAge.promise;
    const saving = f.view.generate();
    await nextTurn();
    f.view.cancelGeneration();
    await f.view.generate();
    assert.equal(f.saves.length, 1);
    assert.equal(f.view.operationPending, true);
    cancelAge.resolve({ success: true, user: { id: 'isolated-user', age: 30 } });
    await saving;
    assert.equal(f.plans.length, 0);
    assert.equal(f.view.operationPending, false);
});
test('plan / age: late plan ignored after cancel', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    const cancelPlan = deferred();
    f.plan = () => cancelPlan.promise;
    const generating = f.view.generate();
    await nextTurn();
    f.view.cancelGeneration();
    await f.view.generate();
    assert.equal(f.plans.length, 1);
    cancelPlan.resolve({ success: true, data: { plan: { id: 'late' } } });
    await generating;
    assert.equal(f.view.generatedPlan, null);
    assert.equal(f.view.loadingPlan, false);
});
test('plan / age: source/save/generation exceptions release loading', { timeout: 5000 }, async () => {
    let f;
    for (const stage of ['age', 'plan', 'source']) {
        f = await planFixture();
        if (stage === 'age') {
            f.view.userAge = '30';
            f.save = async () => { throw Error('network'); };
        }
        else if (stage === 'source') {
            f.history = async () => { throw Error('network'); };
        }
        else {
            f.plan = async () => { throw Error('network'); };
        }
        await f.view.generate();
        assert.equal(f.view.operationPending, false);
        assert.equal(f.view.loadingPlan, false);
        assert.ok(f.view.planError);
    }
});
test('plan / age: leaving prevents the generation stage', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    const leave = deferred();
    f.view.userAge = '30';
    f.save = () => leave.promise;
    const leaving = f.view.generate();
    await nextTurn();
    f.view.aboutToDisappear();
    leave.resolve({ success: true, user: { id: 'isolated-user', age: 30 } });
    await leaving;
    assert.equal(f.plans.length, 0);
});
test('plan / age: account change rejects late plan', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    const owner = deferred();
    f.plan = () => owner.promise;
    const changing = f.view.generate();
    await nextTurn();
    f.token = 'another-token';
    f.user = { id: 'another-user', age: 28 };
    owner.resolve({ success: true, data: { plan: { id: 'late' } } });
    await changing;
    assert.equal(f.view.generatedPlan, null);
    assert.ok(f.view.planError);
});
test('plan / age: source link forwards the returned record and formats its metadata', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    f.view.latestSkinAnalysis.createdAt = '2026-09-15T12:00:00';
    let opened;
    f.view.onViewSkinSource = record => opened = record;
    f.view.viewSource();
    assert.equal(opened._id, 'fixture-source');
    assert.equal(f.view.sourceDetail(), '混合性 · 2026年9月15日');
    assert.equal(opened.skinType.subtype, '偏干');
});
test('plan / age: deleted/missing latest source blocks generation before age mutation', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    f.history = async () => ({ success: true, data: { analyses: [] } });
    f.view.userAge = '30';
    await f.view.generate();
    assert.equal(f.plans.length, 0);
    assert.equal(f.saves.length, 0);
    assert.ok(f.view.planError.includes('肌肤检测'));
});
test('plan / age: account change during source read cannot mutate new account age', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    const sourceGate = deferred();
    f.history = () => sourceGate.promise;
    f.view.userAge = '30';
    const switching = f.view.generate();
    await nextTurn();
    f.token = 'new-token';
    f.user = { id: 'new-user', age: 40 };
    sourceGate.resolve({ success: true, data: { analyses: [{ _id: 'old-source' }] } });
    await switching;
    assert.equal(f.saves.length, 0);
    assert.equal(f.plans.length, 0);
});
test('plan / age: age sheet cancel preserves saved value; save and generation share one account update', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    f.view.editAge();
    f.view.ageDraft = '30';
    f.view.handleNestedBack();
    assert.equal(f.view.userAge, '28');
    assert.equal(f.saves.length, 0);
    f.view.editAge();
    f.view.ageDraft = '30';
    await f.view.saveEditedAge();
    assert.equal(f.view.userAge, '30');
    assert.equal(f.view.showsAgeEditor, false);
    await f.view.generate();
    assert.equal(f.saves.length, 1);
    assert.equal(f.plans[0].age, 30);
});
test('plan / age: cycle validation and user-provided context follow iOS request semantics', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    f.view.isInCycle = true;
    f.view.cycleDay = '8';
    await f.view.generate();
    assert.equal(f.plans.length, 0);
    f.view.cycleDay = '3';
    f.view.customRequirements = '步骤少一点';
    await f.view.generate();
    assert.ok(f.plans[0].customRequirements.includes('周期第3天'));
    assert.equal(f.plans[0].requirement, '补水');
});
test('plan / age: adoption prevents back/reset and another generation', { timeout: 5000 }, async () => {
    let f;
    f = await planFixture();
    let closed = false;
    f.view.onClose = () => closed = true;
    f.view.isAdopting = true;
    f.view.generatedPlan = { id: 'adopting' };
    f.view.close();
    assert.equal(closed, false);
    assert.ok(f.view.generatedPlan);
    await f.view.generate();
    assert.equal(f.plans.length, 0);
});
test('skin race: deletion guards actions and back, emits overlay state, and clears deleted data', { timeout: 5000 }, async () => {
    let f, gate, pending;
    f = skinFixture(), gate = deferred();
    f.deletion = id => gate.promise.then(response => { if (response.success)
        f.records = f.records.filter(r => r._id !== id); return response; });
    pending = f.view.remove('A');
    assert.equal(f.view.deleting, true);
    f.view.select(f.records[1]);
    f.view.editContext();
    f.view.deleteRecord();
    await f.view.analyze('camera');
    await f.view.remove('A');
    assert.equal(f.view.handleBack(), true);
    assert.equal(f.view.result._id, 'A');
    assert.equal(f.view.contextEditing, false);
    assert.equal(f.removed.length, 1);
    assert.equal(f.dialogs.length, 0);
    assert.equal(f.backCount, 0);
    gate.resolve({ success: true });
    await pending;
    assert.equal(f.view.deleting, false);
    assert.equal(f.view.showReport, false);
    assert.equal(f.view.result._id, 'B');
    assert.equal(f.view.contextRecordId, '');
    assert.equal(f.view.contextFeelings.length, 0);
    assert.ok(f.overlays.slice(0, -1).every(Boolean));
});
test('skin race: history started before deletion cannot restore deleted A', { timeout: 5000 }, async () => {
    let f, gate;
    f = skinFixture();
    gate = deferred();
    f.history = () => gate.promise;
    let oldLoad = f.view.load();
    f.history = async () => ({ success: true, data: { analyses: [{ _id: 'B' }] } });
    await f.view.remove('A');
    gate.resolve({ success: true, data: { analyses: [{ _id: 'A' }] } });
    await oldLoad;
    assert.equal(f.view.result._id, 'B');
    assert.equal(f.view.history[0]._id, 'B');
});
test('skin race: overlapping history requests only apply the newest result and loading state', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    let older = deferred(), newer = deferred();
    f.history = () => older.promise;
    let old = f.view.load();
    f.history = () => newer.promise;
    let latest = f.view.load();
    older.resolve({ success: false, message: 'old error' });
    await old;
    assert.equal(f.view.loading, true);
    assert.equal(f.view.historyError, '');
    newer.resolve({ success: true, data: { analyses: [] } });
    await latest;
    assert.equal(f.view.loading, false);
    assert.equal(f.view.history.length, 0);
});
test('skin race: failed deletion preserves record/error across unrelated history refresh', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    f.deletion = async () => ({ success: false, message: 'delete rejected' });
    await f.view.remove('A');
    assert.equal(f.view.result._id, 'A');
    assert.equal(f.view.showReport, true);
    assert.equal(f.view.deleting, false);
    await f.view.load();
    assert.equal(f.view.error, 'delete rejected');
    assert.equal(f.view.historyError, '');
});
test('skin race: successful deletion with failed reload is a history error, not fake empty success or delete failure', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    f.history = async () => ({ success: false, message: 'history offline' });
    await f.view.remove('A');
    assert.equal(f.view.result, null);
    assert.equal(f.view.history.some(r => r._id === 'A'), false);
    assert.equal(f.view.error, '');
    assert.equal(f.view.historyError, 'history offline');
    assert.equal(f.view.deleting, false);
});
test('skin race: context editor is bound to the original record and cannot write A draft into B', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    f.view.editContext();
    f.view.result = f.records[1];
    await f.view.saveContext();
    assert.equal(f.patched.length, 0);
    assert.ok(f.view.contextError.includes('变化'));
    assert.equal(f.view.contextRecordId, 'A');
});
test('skin race: context draft does not mutate source, saving locks actions and failure preserves retryable draft', { timeout: 5000 }, async () => {
    let f, gate, pending;
    f = skinFixture();
    f.view.editContext();
    f.view.contextFeelings.push('出油');
    assert.equal(f.records[0].context.feelings.length, 1);
    gate = deferred();
    f.patch = () => gate.promise;
    pending = f.view.saveContext();
    f.view.select(f.records[1]);
    f.view.closeContext();
    assert.equal(f.view.handleBack(), true);
    await f.view.remove('A');
    await f.view.saveContext();
    assert.equal(f.patched.length, 1);
    assert.equal(f.removed.length, 0);
    assert.equal(f.view.result._id, 'A');
    assert.equal(f.view.contextEditing, true);
    gate.resolve({ success: false, message: 'save rejected' });
    await pending;
    assert.equal(f.view.contextSaving, false);
    assert.equal(f.view.contextEditing, true);
    assert.equal(f.view.contextError, 'save rejected');
    assert.equal(f.view.contextFeelings.length, 2);
});
test('skin race: successful save applies the server record and clears the editor', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    f.view.editContext();
    f.view.contextCondition = '护肤后';
    await f.view.saveContext();
    assert.equal(f.patched[0].id, 'A');
    assert.equal(f.view.result.context.condition, '护肤后');
    assert.equal(f.view.contextEditing, false);
    assert.equal(f.view.contextRecordId, '');
    assert.equal(f.view.contextSaving, false);
});
test('skin race: mismatched server record is rejected without replacing the displayed report', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    f.view.editContext();
    f.patch = async () => ({ success: true, data: { analysis: { _id: 'B', context: { condition: 'wrong' } } } });
    await f.view.saveContext();
    assert.equal(f.view.result._id, 'A');
    assert.equal(f.view.contextEditing, true);
    assert.ok(f.view.contextError);
});
test('skin race: load/delete/save success and failure after destruction cannot mutate state or issue a refresh', { timeout: 5000 }, async () => {
    let f, gate, pending;
    for (const operation of ['load', 'remove', 'saveContext'])
        for (const success of [true, false]) {
            f = skinFixture();
            gate = deferred();
            if (operation === 'load')
                f.history = () => gate.promise;
            else if (operation === 'remove')
                f.deletion = () => gate.promise;
            else {
                f.view.editContext();
                f.patch = () => gate.promise;
            }
            pending = f.view[operation](...(operation === 'remove' ? ['A'] : []));
            f.view.aboutToDisappear();
            const snapshot = JSON.stringify({ result: f.view.result, history: f.view.history, error: f.view.error, historyError: f.view.historyError, contextError: f.view.contextError, reads: f.reads, overlays: f.overlays });
            gate.resolve(success ? { success: true, data: { analyses: [{ _id: 'late' }], analysis: { _id: 'A', context: { condition: 'late' } } } } : { success: false, message: 'late failure' });
            await pending;
            assert.equal(JSON.stringify({ result: f.view.result, history: f.view.history, error: f.view.error, historyError: f.view.historyError, contextError: f.view.contextError, reads: f.reads, overlays: f.overlays }), snapshot);
        }
});
test('skin race: network exceptions release the relevant busy state and preserve actionable errors', { timeout: 5000 }, async () => {
    let f;
    for (const operation of ['load', 'remove', 'saveContext']) {
        f = skinFixture();
        const throwing = async () => { throw Error('network'); };
        if (operation === 'load')
            f.history = throwing;
        else if (operation === 'remove')
            f.deletion = throwing;
        else {
            f.view.editContext();
            f.patch = throwing;
        }
        await f.view[operation](...(operation === 'remove' ? ['A'] : []));
        assert.equal(f.view.loading, false);
        assert.equal(f.view.deleting, false);
        assert.equal(f.view.contextSaving, false);
        assert.ok(f.view.error || f.view.historyError || f.view.contextError);
    }
});
test('skin race: history empty success, analysis error, and editor error remain distinct', { timeout: 5000 }, async () => {
    let f;
    f = skinFixture();
    f.view.error = 'analysis failed';
    f.view.historyError = 'stale read failed';
    f.view.editContext();
    assert.equal(f.view.contextError, '');
    f.view.closeContext();
    assert.equal(f.view.contextRecordId, '');
    f.view.result = null;
    f.records = [];
    await f.view.load();
    assert.equal(f.view.result, null);
    assert.equal(f.view.historyError, '');
    assert.equal(f.view.error, 'analysis failed');
});

test('home: initial load failure leaves an error state instead of confirmed empty data', { timeout: 5000 }, async () => {
    const f = homeFixture();
    f.active = async () => ({ success: false, message: 'initial read failed' });
    await f.view.load();
    assert.equal(f.view.plan, null);
    assert.equal(f.view.loading, false);
    assert.equal(f.view.error, 'initial read failed');
    // These two assertions inspect source wiring only; they do not render ArkUI.
    const source = readComponentSource('entry/src/main/ets/pages/HomeView.ets');
    assert.match(source, /else\s+if\s*\(!this\.error\)\s*\{/);
    assert.match(source, /kind:\s*AISkinStateKind\.Error,\s*onRetry:\s*\(\)\s*=>\s*\{\s*this\.load\(\)\s*\}/);
});

test('home: retry installs the returned plan and clears the previous error', { timeout: 5000 }, async () => {
    const f = homeFixture();
    f.active = async () => ({ success: false, message: 'offline' });
    await f.view.load();
    const plan = { _id: 'recovered-plan' };
    f.active = async () => ({ success: true, data: { plan } });
    await f.view.load();
    assert.equal(f.view.plan, plan);
    assert.equal(f.view.error, '');
    assert.equal(f.view.loading, false);
    assert.equal(f.reads, 2);
});

test('home: failed responses and thrown requests preserve the previously loaded plan', { timeout: 5000 }, async () => {
    for (const failure of ['response', 'exception']) {
        const f = homeFixture();
        const previousPlan = { _id: 'previous-plan' };
        f.view.plan = previousPlan;
        f.active = async () => {
            if (failure === 'exception') throw new Error('network failed');
            return { success: false, message: 'request rejected' };
        };
        await f.view.load();
        assert.equal(f.view.plan, previousPlan);
        assert.ok(f.view.error);
        assert.equal(f.view.loading, false);
    }
});

test('home: an older response cannot overwrite the latest retry result', { timeout: 5000 }, async () => {
    for (const success of [true, false]) {
        const f = homeFixture();
        const older = deferred();
        f.active = () => older.promise;
        const pendingOlder = f.view.load();
        const latestPlan = { _id: 'latest-plan' };
        f.active = async () => ({ success: true, data: { plan: latestPlan } });
        await f.view.load();
        older.resolve(success ? { success: true, data: { plan: { _id: 'old-plan' } } } : { success: false, message: 'late error' });
        await pendingOlder;
        assert.equal(f.view.plan, latestPlan);
        assert.equal(f.view.error, '');
        assert.equal(f.view.loading, false);
    }
});

test('home: a successful no-plan response is distinct from a read error', { timeout: 5000 }, async () => {
    const f = homeFixture();
    f.view.plan = { _id: 'previous-plan' };
    f.view.error = 'previous error';
    await f.view.load();
    assert.equal(f.view.plan, null);
    assert.equal(f.view.error, '');
    assert.equal(f.view.loading, false);
});

test('home: synchronous openPlan consumption prepares once and does not repeat on return', { timeout: 5000 }, async () => {
    const f = homeFixture();
    f.view.openPlan = true;
    f.view.onConsumeOpenPlan = () => {
        f.consumed++;
        f.view.openPlan = false;
    };
    f.view.aboutToAppear();
    await nextTurn();
    assert.equal(f.consumed, 1);
    assert.equal(f.preparationReads, 1);
    assert.equal(f.view.creating, true);
    f.view.aboutToDisappear();
    f.view.creating = false;
    f.view.aboutToAppear();
    await nextTurn();
    assert.equal(f.consumed, 1);
    assert.equal(f.preparationReads, 1);
    assert.equal(f.view.creating, false);
    assert.equal(f.reads, 2);
    // Parent prop reset is checked structurally; real prop propagation needs native QA.
    const index = readComponentSource('entry/src/main/ets/pages/Index.ets');
    assert.match(index, /onConsumeOpenPlan:\s*\(\)\s*=>\s*\{\s*this\.openPlan\s*=\s*false\s*\}/);
});
