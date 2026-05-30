# AGENTS.md — Paper Blossoms

## Build & Test Commands

```bash
# Build everything (app + tests)
qmake PaperBlossomsSolution.pro && make

# Build just the app
cd PaperBlossoms && qmake PaperBlossoms.pro && make

# Build just the tests
cd TestPaperBlossoms && qmake TestPaperBlossoms.pro && make

# Run all tests
./TestPaperBlossoms/TestPaperBlossoms

# Run a single test function by name
./TestPaperBlossoms/TestPaperBlossoms test_dal_qsl_getclans

# List available test functions
./TestPaperBlossoms/TestPaperBlossoms -functions

# Clean build
make clean && qmake && make

# Run the application
./PaperBlossoms/PaperBlossoms
```

## Project Structure

```
PaperBlossoms/              # Main application
  PaperBlossoms.pro         # qmake project file
  src/
    main.cpp                # Entry point
    mainwindow.cpp/h        # Main window
    character.cpp/h         # Character data model
    enums.h                 # Enum namespaces for data column indices
    dynamicchoicewidget.cpp/h
    ringviewer.cpp/h
    clicklabel.cpp/h
    pboutputdata.cpp/h
    dialog/                 # QDialog subclasses
      aboutdialog, addadvancedialog, addbonddialog, adddisadvdialog,
      additemdialog, addtitledialog, dblocalisationeditordialog,
      edituserdescriptionsdialog, renderdialog
    repository/             # Data access (Repository pattern)
      dataaccesslayer.cpp/h # Direct DB access
      abstractrepository.h  # Base class taking DataAccessLayer*
      clansrepository, familiesRepository, schoolsrepository, etc.
    tabs/                   # Tab pages for main window
      advancementpage, backgroundpage, bondspage, characterdatapage,
      equipmentpage, personaltraitspage
    tools/                  # Utilities
      common.cpp, developer.cpp, export.cpp, file.cpp, import.cpp
    dependency/             # Dependency injection
      databasedependency.cpp/h  # Holds all repository pointers
      dependencybuilder.cpp/h   # Factory that constructs deps
    characterwizard/        # New character wizard (7 pages)
      newcharacterwizard, newcharwizardpage1-7
  ui/                       # Qt Designer .ui files (18 files)
  data/                     # DB, JSON, Python scripts, translations
  resources.qrc             # Qt resource file
TestPaperBlossoms/          # Qt Test suite
  TestPaperBlossoms.pro     # Test project file
  tst_testmain.cpp          # All test methods
  testresources.qrc
```

## Code Style Guidelines

### Imports & Includes

- **Local headers first** (quotes), **Qt headers second** (angle brackets), **blank line** between groups.
- Local includes use relative paths: `#include "../repository/dataaccesslayer.h"`
- Qt includes use `<QModule/Class>`: `#include <QSqlQuery>`, `#include <QDebug>`
- Each group sorted alphabetically.
- `.cpp` files `#include` their own `.h` first (matching basename), then others.
- `.cpp` files that need generated UI headers: `#include "ui_mainwindow.h"`
- Header guards: `#ifndef FILENAME_H` / `#define FILENAME_H` / `#endif // FILENAME_H`
- Test file includes both `.h` and `.cpp` files directly.

### Naming Conventions

| Category | Convention | Example |
|---|---|---|
| Classes | PascalCase | `DataAccessLayer`, `MainWindow` |
| Files (`.h`/`.cpp`) | PascalCase, matching class | `schoolsrepository.cpp` / `SchoolsRepository.h` |
| Member variables | camelCase | `curCharacter`, `m_dirtyDataFlag` |
| Methods | camelCase | `qsl_getclans()`, `on_actionNew_triggered()` |
| Enum namespaces | PascalCase | `ItemData`, `Adv_Disadv`, `TechQuery` |
| Enum constants | UPPER_CASE | `NAME`, `SHORT_DESC`, `REFERENCE_BOOK` |
| Private slots | `on_objectName_signalName()` | `on_actionNew_triggered()` |
| UI members | `ui->widgetName` | `ui->tabWidget`, `ui->character_name_label` |

### Repository Method Naming Prefixes

- `qsl_` → returns `QStringList`
- `qs_` → returns `QString`
- `i_` → returns `int`
- `qsm_` → takes `QSqlQueryModel*` parameter
- `ql_` → returns `QList<QStringList>`

### Formatting

- Braces: Allman style (brace on next line) for functions, K&R for control flow.
- Indentation: 4 spaces (no tabs).
- License header (GPLv3 block) required at top of every source file — 22 lines.
- No trailing whitespace.

### Types & Qt Idioms

- Use Qt types: `QString` not `std::string`, `QStringList` not `std::vector<QString>`.
- Use `QMap` / `QList` over `std::map` / `std::vector` unless interop requires.
- Pointers to Qt widgets/QObjects stored as raw pointers (Qt parent ownership).
- Use `const` for unchanged parameters: `const QString clan`, `const QString &string`.
- Class members are public unless there's a reason to encapsulate.

### Error Handling

- `qWarning()` for recoverable errors: `qWarning() << "ERROR: " << db.lastError();`
- `qDebug()` for diagnostics and flow tracing (stripped in release builds).
- `QMessageBox` for user-facing errors with Yes/No/Cancel buttons and `tr()` for i18n.
- Validate locale strings against an allowlist to avoid injection: `if(s.toLower()=="en")`.
- SQL errors logged but rarely checked via return value — prefer `qWarning()` on `db.lastError()`.

### Testing

- Test class inherits `QObject`, uses `Q_OBJECT` macro, includes `.moc` at end of `.cpp`.
- Test methods prefixed `test_`, named `test_area_functionBeingTested()`.
- Use `QVERIFY(condition)`, `QVERIFY2(condition, message)`, `QCOMPARE(actual, expected)`.
- `initTestCase()` / `cleanupTestCase()` for setup/teardown.
- Test fixtures built via `DependencyBuilder` in constructor.

### Design Patterns

- **Repository pattern**: each DB table group has a `XxxRepository` class extending `AbstractRepository`.
- **Dependency injection**: `DatabaseDependency` aggregates all repositories and `DataAccessLayer`; built by `DependencyBuilder`.
- **Signal-slot**: Qt signals/slots for UI interactions (auto-connect naming convention).
- **Model-View**: `QSqlQueryModel` / `QStandardItemModel` with Qt view widgets.
- No exceptions (`try`/`catch`) used in this codebase.

### Translation (i18n)

- UI strings use `tr("string")` for runtime translation.
- Database locale strings set at startup via `--locale` arg or `settings.ini`.
- Supported locales: `en`, `fr`, `es`, `de`, `test`.
- Translation files: `paperblossoms_XX.ts` (source) / `.qm` (compiled).
