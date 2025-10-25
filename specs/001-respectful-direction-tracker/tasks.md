# Task Management: Respectful Direction Tracker

**Project**: あしむけれん (Respectful Direction Tracker)
**Feature Branch**: `001-respectful-direction-tracker`
**Last Updated**: 2025-10-20

---

## Overview

This is the **main task index** for the "あしむけれん" (Respectful Direction Tracker) project.

Tasks are organized into **2 independent tracks**:

1. **Feature Development Track** (`tasks-features.md`) - 機能実装トラック
2. **Store Deployment Track** (`tasks-deployment.md`) - ストア公開トラック

---

## 📂 Task Tracks

### Track 1: Feature Development (機能実装)

**File**: [`tasks-features.md`](./tasks-features.md)

**Purpose**: アプリの機能実装・改善タスク

**Scope**:
- ✅ Phase 1-8: Core Features (全107タスク完了)
  - Setup, Foundational, User Stories 1-3
  - 日本語化, Polish, MVVM + Riverpod Migration
- 🔮 Phase 9+: Future Enhancements (未計画)

**Current Status**: 95/107 tasks complete (89%)

**Next Steps**:
- Complete Phase 7 (Polish) remaining tasks
- Complete Phase 8 (Compass screen migration) when ready

---

### Track 2: Store Deployment (ストア公開)

**File**: [`tasks-deployment.md`](./tasks-deployment.md)

**Purpose**: アプリストアへの公開・運用タスク

**Scope**:
- ⏳ Phase D1: Pre-Release Preparation (9/18タスク完了)
  - API Security (Layer 1 & 3 ✅, Layer 2 ⏸️MANUAL)
  - App ID変更 ✅
  - アイコン・ポリシー準備 ⏸️
- ⏸️ Phase D2: Android Play Store Release (0/8タスク)
- ⏸️ Phase D3: iOS App Store Release (0/9タスク)
- ⏸️ Phase D4: Post-Release Maintenance (0/5タスク)

**Current Status**: 9/39 tasks complete (23%)

**Next Steps**:
1. **MANUAL Tasks** (ユーザーが実施):
   - T-D1.1.4: Google Cloud ConsoleでAPI制限設定
   - T-D1.1.5: SHA-1証明書フィンガープリント登録
   - T-D1.1.6: API使用量監視・請求アラート設定
   - T-D1.1.7: APIクォータ制限設定
2. アプリアイコン準備 (T-D1.2.2)
3. プライバシーポリシー作成 (T-D1.3.1)
4. 実機最終確認 (T-D1.4.1)

---

## 🎯 Current Focus

### Active Work

**機能開発トラック**: Phase 7 Polish 残タスク (4タスク)
- Loading indicators
- Empty state messages
- Navigation structure (BottomNavigationBar)
- Documentation updates

**ストア公開トラック**: Phase D1 Pre-Release Preparation (9タスク残り)
- **最優先**: Layer 2 Security (4 MANUAL tasks)
- アイコン・ポリシー準備
- 実機最終確認

---

## 📊 Progress Summary

### Overall Progress

| Track | Phase | Status | Progress |
|-------|-------|--------|----------|
| **Features** | Phase 1-6 | ✅ Complete | 52/52 (100%) |
| **Features** | Phase 7 Polish | ⏳ In Progress | 5/9 (56%) |
| **Features** | Phase 8 MVVM | ✅ 80% Complete | 32/40 (80%) |
| **Deployment** | Phase D1 Pre-Release | ⏳ In Progress | 9/18 (50%) |
| **Deployment** | Phase D2 Android | ⏸️ Pending | 0/8 (0%) |
| **Deployment** | Phase D3 iOS | ⏸️ Future | 0/9 (0%) |
| **Deployment** | Phase D4 Maintenance | ⏸️ Future | 0/5 (0%) |

### Total Tasks

- **Feature Track**: 107 tasks (95 complete, 12 remaining)
- **Deployment Track**: 39 tasks (9 complete, 30 remaining)
- **Grand Total**: 146 tasks (104 complete, 42 remaining)

---

## 🚀 Quick Start Guide

### For Feature Development

1. Open [`tasks-features.md`](./tasks-features.md)
2. Find the phase you're working on (Phase 7 or Phase 8)
3. Pick a task marked `[ ]` (pending)
4. Implement the task
5. Mark as `[x]` (complete) and commit

### For Store Deployment

1. Open [`tasks-deployment.md`](./tasks-deployment.md)
2. Start with Phase D1 (Pre-Release Preparation)
3. Complete **MANUAL tasks** (T-D1.1.4 ~ T-D1.1.7) via Google Cloud Console
4. Complete remaining D1 tasks (icon, privacy policy, testing)
5. Proceed to Phase D2 (Android release)

---

## 📋 Task Format

### Feature Tasks

```
[ID] [P?] [Story] Description
```

- `[ID]`: Task number (T001, T002, etc.)
- `[P]`: Can run in parallel (different files, no dependencies)
- `[Story]`: Which user story (US1, US2, US3, L10n, etc.)

**Example**: `T053 [P] [L10n] RegistrationListScreen の日本語化`

### Deployment Tasks

```
[ID] [MANUAL?] [LAYER X?] Description
```

- `[ID]`: Task number (T-D1.1.1, T-D2.1.1, etc.)
- `[MANUAL]`: Requires manual execution by user
- `[LAYER X]`: Security layer (1=Environment, 2=Cloud Console, 3=Obfuscation)

**Example**: `T-D1.1.4 [MANUAL] [LAYER 2 - CRITICAL] Google Maps API制限設定`

---

## 🔗 Related Documentation

### Specification Documents
- **Feature Spec**: [`spec.md`](./spec.md) - Detailed requirements
- **Implementation Plan**: [`plan.md`](./plan.md) - Technical approach
- **Data Model**: [`data-model.md`](./data-model.md) - Database schema
- **Contracts**: [`contracts/`](./contracts/) - Service interfaces

### Guides
- **Deployment Guide**: [`DEPLOYMENT.md`](../../DEPLOYMENT.md) - Step-by-step store publication
- **Quick Start**: [`quickstart.md`](./quickstart.md) - Setup instructions
- **Migration Notes**: [`migration-notes.md`](./migration-notes.md) - MVVM + Riverpod migration

### Project Management
- **Constitution**: [`../../.specify/memory/constitution.md`](../../.specify/memory/constitution.md) - Project principles
- **CLAUDE.md**: [`../../CLAUDE.md`](../../CLAUDE.md) - Developer guide

---

## ⚙️ Workflow

### Adding New Feature Tasks

1. Open [`tasks-features.md`](./tasks-features.md)
2. Add new phase (e.g., Phase 9, Phase 10) in "Future Enhancements" section
3. Define tasks with proper format
4. Update task summary

### Adding New Deployment Tasks

1. Open [`tasks-deployment.md`](./tasks-deployment.md)
2. Add tasks to appropriate phase (D1, D2, D3, or D4)
3. Mark as `[MANUAL]` if user intervention required
4. Update task summary

### Marking Tasks Complete

1. Implement the task
2. Change `[ ]` to `[x]`
3. Run verification steps (e.g., `flutter analyze`, manual testing)
4. Commit changes with descriptive message

---

## 📝 Notes

### Separation Rationale

**Why 2 tracks?**
- **Independence**: Features can be developed without blocking store submission
- **Clarity**: Different team members can focus on different tracks
- **Scalability**: Easy to add new features or deployment platforms (web, desktop)

### Track Interaction

- Feature development is **prerequisite** for deployment
- Deployment tasks reference feature completion status
- Both tracks share core documentation (spec.md, plan.md, CLAUDE.md)

### Future Expansion

- **Feature Track**: Add Phase 9+ for new features (notifications, cloud sync, etc.)
- **Deployment Track**: Add Phase D5+ for web/desktop deployment

---

## 📞 Support

For questions about:
- **Feature tasks**: See [`tasks-features.md`](./tasks-features.md) or [`CLAUDE.md`](../../CLAUDE.md)
- **Deployment tasks**: See [`tasks-deployment.md`](./tasks-deployment.md) or [`DEPLOYMENT.md`](../../DEPLOYMENT.md)
- **Project structure**: See [`.specify/memory/constitution.md`](../../.specify/memory/constitution.md)

---

**Last Updated**: 2025-10-20
**Version**: 2.0.0 (2-track structure)
