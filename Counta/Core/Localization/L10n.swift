import Foundation

enum L10n {
    static func string(_ resource: LocalizedStringResource) -> String {
        String(localized: resource)
    }

    enum Titles {
        static let incomeStatement = LocalizedStringResource("title.incomeStatement", defaultValue: "损益表")
        static let balanceSheet = LocalizedStringResource("title.balanceSheet", defaultValue: "资产负债表")
        static let journal = LocalizedStringResource("title.journal", defaultValue: "日记账")
        static let settings = LocalizedStringResource("title.settings", defaultValue: "设置")
        static let about = LocalizedStringResource("about.title", defaultValue: "关于")
    }

    enum Tabs {
        static let incomeStatement = LocalizedStringResource("tab.incomeStatement", defaultValue: "损益表")
        static let balanceSheet = LocalizedStringResource("tab.balanceSheet", defaultValue: "资产负债")
        static let journal = LocalizedStringResource("tab.journal", defaultValue: "日记账")
        static let settings = LocalizedStringResource("tab.settings", defaultValue: "设置")
    }

    enum Common {
        static let connecting = LocalizedStringResource("common.connecting", defaultValue: "连接中...")
        static let checkFavaSettings = LocalizedStringResource("common.checkFavaSettings", defaultValue: "请检查 Fava 连接设置")
    }

    enum Onboarding {
        static let titleOnboarding = LocalizedStringResource("onboarding.title.onboarding", defaultValue: "欢迎使用 Counta")
        static let titleSettings = LocalizedStringResource("onboarding.title.settings", defaultValue: "连接 Fava")
        static let subtitleOnboarding = LocalizedStringResource("onboarding.subtitle.onboarding", defaultValue: "请输入 Fava 地址以连接账本数据")
        static let subtitleSettings = LocalizedStringResource("onboarding.subtitle.settings", defaultValue: "更新 Fava 地址和登录信息")
        static let actionStart = LocalizedStringResource("onboarding.action.start", defaultValue: "开始使用")
        static let actionSave = LocalizedStringResource("onboarding.action.save", defaultValue: "保存")
        static let navigationTitle = LocalizedStringResource("onboarding.navTitle.favaConnection", defaultValue: "Fava 连接")
        static let favaAddress = LocalizedStringResource("onboarding.favaAddress", defaultValue: "Fava 地址")
        static let username = LocalizedStringResource("onboarding.username", defaultValue: "用户名")
        static let password = LocalizedStringResource("onboarding.password", defaultValue: "密码")
        static let basicAuthToggle = LocalizedStringResource("onboarding.toggle.basicAuth", defaultValue: "需要登录（Basic Auth）")
    }

    enum Settings {
        static let sectionConnection = LocalizedStringResource("settings.section.connection", defaultValue: "连接")
        static let sectionDisplay = LocalizedStringResource("settings.section.display", defaultValue: "显示")
        static let sectionAbout = LocalizedStringResource("settings.section.about", defaultValue: "关于")
        static let favaServer = LocalizedStringResource("settings.row.favaServer", defaultValue: "Fava 服务器")
        static let notSet = LocalizedStringResource("settings.row.notSet", defaultValue: "未设置")
        static let currencyDisplay = LocalizedStringResource("settings.row.currencyDisplay", defaultValue: "货币显示")
        static let currencyUncommonSymbolNote = LocalizedStringResource("settings.row.currencyUncommonSymbolNote", defaultValue: "非常见货币将使用符号¤")
        static let aboutCounta = LocalizedStringResource("settings.row.aboutCounta", defaultValue: "关于 Counta")
        static let aboutTagline = LocalizedStringResource("settings.about.tagline", defaultValue: "基于 Beancount 的财务管理")
        static let aboutVersion = LocalizedStringResource("settings.about.version", defaultValue: "版本")
        static let aboutBuild = LocalizedStringResource("settings.about.build", defaultValue: "构建")
        static let aboutBeancountWebsite = LocalizedStringResource("settings.about.beancountWebsite", defaultValue: "Beancount 官网")
    }

    enum CurrencySettings {
        static let title = LocalizedStringResource("currencySettings.title", defaultValue: "货币设置")
        static let sectionDisplay = LocalizedStringResource("currencySettings.section.display", defaultValue: "显示")
        static let footerUncommonCurrencySymbolNote = LocalizedStringResource(
            "currencySettings.footer.uncommonCurrencySymbolNote",
            defaultValue: "当货币没有常见符号时，将使用通用货币符号 ¤。"
        )
    }

    enum CurrencyDisplayMode {
        static let symbolTitle = LocalizedStringResource("currencyDisplayMode.symbol.title", defaultValue: "符号")
        static let codeTitle = LocalizedStringResource("currencyDisplayMode.code.title", defaultValue: "缩写")
        static let symbolItem = LocalizedStringResource("currencyDisplayMode.symbol.item", defaultValue: "符号 ($)")
        static let codeItem = LocalizedStringResource("currencyDisplayMode.code.item", defaultValue: "缩写 (USD)")
    }

    enum IncomeStatement {
        static let emptyTitle = LocalizedStringResource("incomeStatement.empty.title", defaultValue: "暂无损益表数据")
        static let netIncome = LocalizedStringResource("incomeStatement.netIncome", defaultValue: "净收入")
        static let income = LocalizedStringResource("incomeStatement.income", defaultValue: "收入")
        static let expenses = LocalizedStringResource("incomeStatement.expenses", defaultValue: "支出")
    }

    enum BalanceSheet {
        static let emptyTitle = LocalizedStringResource("balanceSheet.empty.title", defaultValue: "暂无资产负债表数据")
        static let netWorth = LocalizedStringResource("balanceSheet.netWorth", defaultValue: "净资产")
        static let assets = LocalizedStringResource("balanceSheet.assets", defaultValue: "资产")
        static let liabilities = LocalizedStringResource("balanceSheet.liabilities", defaultValue: "负债")
        static let equity = LocalizedStringResource("balanceSheet.equity", defaultValue: "权益")
    }

    enum Journal {
        static let emptyTitle = LocalizedStringResource("journal.empty.title", defaultValue: "暂无日记账数据")
        static let searchPrompt = LocalizedStringResource("journal.search.prompt", defaultValue: "搜索交易")
        static let loadMore = LocalizedStringResource("journal.loadMore", defaultValue: "加载更多")

        static let detailOverview = LocalizedStringResource("journalDetail.overview", defaultValue: "概览")
        static let detailDate = LocalizedStringResource("journalDetail.date", defaultValue: "日期")
        static let detailKind = LocalizedStringResource("journalDetail.kind", defaultValue: "类型")
        static let detailStatus = LocalizedStringResource("journalDetail.status", defaultValue: "状态")
        static let detailFlag = LocalizedStringResource("journalDetail.flag", defaultValue: "标记")
        static let detailAmount = LocalizedStringResource("journalDetail.amount", defaultValue: "金额")
        static let detailDescription = LocalizedStringResource("journalDetail.description", defaultValue: "描述")
        static let detailPayee = LocalizedStringResource("journalDetail.payee", defaultValue: "交易方")
        static let detailNarration = LocalizedStringResource("journalDetail.narration", defaultValue: "摘要")
        static let detailPostings = LocalizedStringResource("journalDetail.postings", defaultValue: "分录")
        static let detailNoPostings = LocalizedStringResource("journalDetail.noPostings", defaultValue: "暂无分录")

        static let kindTransaction = LocalizedStringResource("journalKind.transaction", defaultValue: "交易")
        static let kindOpen = LocalizedStringResource("journalKind.open", defaultValue: "开账")
        static let kindBalance = LocalizedStringResource("journalKind.balance", defaultValue: "余额")
        static let kindPrice = LocalizedStringResource("journalKind.price", defaultValue: "价格")
        static let kindNote = LocalizedStringResource("journalKind.note", defaultValue: "备注")
        static let kindPad = LocalizedStringResource("journalKind.pad", defaultValue: "调整")
        static let kindOther = LocalizedStringResource("journalKind.other", defaultValue: "其他")

        static let statusCleared = LocalizedStringResource("journalStatus.cleared", defaultValue: "已清算")
        static let statusPending = LocalizedStringResource("journalStatus.pending", defaultValue: "待确认")
        static let statusOther = LocalizedStringResource("journalStatus.other", defaultValue: "其他")
    }

    enum AccountDetail {
        static let sectionAccountInfo = LocalizedStringResource("accountDetail.section.accountInfo", defaultValue: "账户信息")
        static let fullName = LocalizedStringResource("accountDetail.fullName", defaultValue: "完整名称")
        static let type = LocalizedStringResource("accountDetail.type", defaultValue: "类型")
        static let sectionBalance = LocalizedStringResource("accountDetail.section.balance", defaultValue: "余额")
        static let currentBalance = LocalizedStringResource("accountDetail.currentBalance", defaultValue: "当前余额")
        static let sectionRelatedTransactions = LocalizedStringResource("accountDetail.section.relatedTransactions", defaultValue: "相关交易")
        static let noRelatedTransactions = LocalizedStringResource("accountDetail.noRelatedTransactions", defaultValue: "暂无相关交易")
    }

    enum AccountType {
        static let assets = LocalizedStringResource("accountType.assets", defaultValue: "资产")
        static let liabilities = LocalizedStringResource("accountType.liabilities", defaultValue: "负债")
        static let income = LocalizedStringResource("accountType.income", defaultValue: "收入")
        static let expenses = LocalizedStringResource("accountType.expenses", defaultValue: "支出")
        static let equity = LocalizedStringResource("accountType.equity", defaultValue: "权益")
    }

    enum Errors {
        static let missingBaseURL = LocalizedStringResource("error.fava.missingBaseURL", defaultValue: "请先在设置中配置 Fava 地址")
        static let invalidBaseURL = LocalizedStringResource("error.fava.invalidBaseURL", defaultValue: "Fava 地址无效，请检查设置")
        static let invalidResponse = LocalizedStringResource("error.fava.invalidResponse", defaultValue: "服务器响应无效，请稍后重试")
        static let authFailed = LocalizedStringResource("error.fava.authFailed", defaultValue: "认证失败，请检查用户名和密码")

        static func httpStatus(_ statusCode: Int) -> String {
            let format = NSLocalizedString("error.fava.httpStatus", comment: "HTTP status code error")
            return String(format: format, locale: .current, Int64(statusCode))
        }

        static let decodingIncomeStatement = LocalizedStringResource(
            "error.fava.decoding.incomeStatement",
            defaultValue: "无法解析损益表数据"
        )
        static let decodingBalanceSheet = LocalizedStringResource(
            "error.fava.decoding.balanceSheet",
            defaultValue: "无法解析资产负债表数据"
        )
        static let decodingJournal = LocalizedStringResource(
            "error.fava.decoding.journal",
            defaultValue: "无法解析日记账数据"
        )
        static let decodingAccountDetail = LocalizedStringResource(
            "error.fava.decoding.accountDetail",
            defaultValue: "无法解析账户明细数据"
        )

        static func requestFailed(_ error: Error) -> String {
            let format = NSLocalizedString("error.fava.requestFailed", comment: "Network request failed")
            return String(format: format, locale: .current, error.localizedDescription)
        }

        static let invalidPage = LocalizedStringResource(
            "error.journal.invalidPage",
            defaultValue: "页码无效，请稍后重试"
        )
        static let noMoreJournalData = LocalizedStringResource(
            "error.journal.noMoreData",
            defaultValue: "暂无更多日记账数据"
        )

        static let vmLoadIncomeStatement = LocalizedStringResource(
            "error.viewModel.loadIncomeStatement",
            defaultValue: "无法加载损益表数据"
        )
        static let vmLoadBalanceSheet = LocalizedStringResource(
            "error.viewModel.loadBalanceSheet",
            defaultValue: "无法加载资产负债表数据"
        )
        static let vmLoadJournal = LocalizedStringResource(
            "error.viewModel.loadJournal",
            defaultValue: "无法加载日记账数据"
        )
        static let vmLoadJournalMore = LocalizedStringResource(
            "error.viewModel.loadJournalMore",
            defaultValue: "无法加载更多日记账数据"
        )
        static let vmLoadAccountDetail = LocalizedStringResource(
            "error.viewModel.loadAccountDetail",
            defaultValue: "无法加载账户明细数据"
        )

        static let onboardingInvalidURLPrefix = LocalizedStringResource(
            "error.onboarding.invalidURLPrefix",
            defaultValue: "请输入有效的链接（以 http 或 https 开头）"
        )
        static let onboardingMissingUsername = LocalizedStringResource(
            "error.onboarding.missingUsername",
            defaultValue: "请输入用户名"
        )
        static let onboardingMissingPassword = LocalizedStringResource(
            "error.onboarding.missingPassword",
            defaultValue: "请输入密码"
        )
        static let onboardingUnableResolveFavaURL = LocalizedStringResource(
            "error.onboarding.unableResolveFavaURL",
            defaultValue: "无法解析 Fava 地址"
        )
        static let onboardingUnableSavePassword = LocalizedStringResource(
            "error.onboarding.unableSavePassword",
            defaultValue: "无法保存密码，请重试"
        )

        static let favaResolverInvalidURL = LocalizedStringResource(
            "favaResolver.invalidURL",
            defaultValue: "请输入有效的 Fava 地址"
        )
        static let favaResolverInvalidResponse = LocalizedStringResource(
            "favaResolver.invalidResponse",
            defaultValue: "无法解析 Fava 地址，请检查服务器是否可访问"
        )
        static let favaResolverMissingLedgerPath = LocalizedStringResource(
            "favaResolver.missingLedgerPath",
            defaultValue: "无法识别账本路径，请检查 Fava 首页是否可访问"
        )

        static func favaResolverRequestFailed(_ error: Error) -> String {
            let format = NSLocalizedString("favaResolver.requestFailed", comment: "Fava connect failed")
            return String(format: format, locale: .current, error.localizedDescription)
        }

        static func keychainUnhandledStatus(_ status: Int) -> String {
            let format = NSLocalizedString("error.keychain.unhandledStatus", comment: "Keychain error status")
            return String(format: format, locale: .current, Int64(status))
        }
    }
}
