• Findings

  - Hardcoded onboarding/setting strings: Counta/Features/Onboarding/Views/WelcomeView.swift:11, Counta/Features/Settings/Views/SettingsView.swift:16, Counta/Features/Settings/Views/
    CurrencySettingsView.swift:9
  - Tab & report UI literals: Counta/Features/MainTab/Views/MainTabView.swift:14, Counta/Features/IncomeStatement/Views/IncomeStatementView.swift:24, Counta/Features/BalanceSheet/Views/
    BalanceSheetView.swift:25, Counta/Features/Journal/Views/JournalView.swift:25
  - Detail screens & enum labels: Counta/Features/AccountDetail/Views/AccountDetailView.swift:42, Counta/Features/Journal/Views/JournalEntryDetailView.swift:27, Counta/Core/Models/
    CurrencyDisplayMode.swift:12
  - Errors & date formats: Counta/Features/IncomeStatement/Services/IncomeStatementService.swift:74, Counta/Core/Services/FavaConnectionSupport.swift:33, Counta/Features/IncomeStatement/
    ViewModels/IncomeStatementViewModel.swift:68, Counta/Core/Extensions/Date+Extensions.swift:34

  Step-by-Step Plan

  - Step 1: Decide source language (recommend zh-Hans first to match current strings) and add zh-Hans/en regions; create a String Catalog for UI + errors (or split “UI” and “Errors”
    tables) in the app target.
  - Step 2: Add a small L10n helper using LocalizedStringResource/String(localized:), including formatted helpers for statusCode and error.localizedDescription, so literals never appear in
    views/services.
  - Step 3: Migrate SwiftUI views: replace literals in Text, Section, NavigationTitle, ContentUnavailableView, Label, TextField, Toggle, Picker, and .searchable prompts; change computed
    Context titles in Welcome to return localized resources.
  - Step 4: Localize enum/model display labels (AccountType, CurrencyDisplayMode, JournalEntryKind/Status) and ensure only UI labels change — keep server data like account names/narrations
    untouched.
  - Step 5: Centralize validation/error strings (shared error type or common keys) and update services/viewmodels to use localized keys instead of Chinese fallback strings.
  - Step 6: Replace Chinese-specific date strings with locale-aware RelativeDateTimeFormatter or Date.FormatStyle, then QA with language overrides and pseudo‑localization to catch
    truncation.
