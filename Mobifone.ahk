﻿#requires AutoHotkey v2.0
#SingleInstance force

; =====================
; Helper Functions (Clean Code)
; =====================
; GET CLIPBOARD TEXT
GetClipboardText() {
    prevClipboard := A_Clipboard
    Send "^c"
    Sleep 300
    text := Trim(A_Clipboard)
    A_Clipboard := prevClipboard
    return text
}
; SHOW GUI WITH ESCAPE
ShowGuiWithEsc(title, guiBuilder) {
    gui := Gui(, title)
    guiBuilder.Call(gui)
    gui.OnEvent("Escape", (*) => WinClose(title))
    gui.Show()
}

ArrayIncludes(array, value) {
    for _, item in array {
        if item = value
            return true
    }
    return false
}
CheckPhonePrefix(phone, prefixList, carrier, hotline) {
    prefix := SubStr(phone, 1, 2)
    for _, p in prefixList {
        if (prefix = p) {
            return Format("Số điện thoại {1} - {2} `n`nTổng đài: {3}", phone, carrier, hotline)
        }
    }
    return ""
}

; =====================
; Hotkeys & Main Logic (Clean Code)
; =====================
; ALWAYS ON TOP
^+t:: {
    alwaysOnTopMark := "! "
    winTitle := WinGetTitle("A")
    exStyle := WinGetExStyle(winTitle)
    if (exStyle & 0x8) {
        WinSetAlwaysOnTop 0, winTitle
        WinSetTitle (RegExReplace(winTitle, alwaysOnTopMark)), winTitle
    } else {
        WinSetAlwaysOnTop 1, winTitle
        WinSetTitle alwaysOnTopMark winTitle, winTitle
    }
}

; DATE CALCULATOR
^+q:: {
    dateStr := GetClipboardText()
    try {
        baseDate := DateParse(dateStr)
    } catch {
        baseDate := A_Now
    }
    ShowGuiWithEsc("Date Calculator", ShowDateAddGuiBuilder.Bind(baseDate))
}

ShowDateAddGuiBuilder(gui, baseDate) {
    line := "-------------------------------------------------------------------------"
    gui.Add("Text", "x10 y20 cRed", "Ngày hiện tại")
    gui.Add("Text", "xm", line)
    gui.Add("Text", "x10 y60 cBlue", "+ 04 ngày:")
    gui.Add("Text", "xm", line)
    gui.Add("Text", "x10 y100 cBlue", "+ 10 ngày:")
    gui.Add("Text", "xm", line)
    gui.Add("Text", "x10 y140 cBlue", "+ 14 ngày:")
    gui.Add("Text", "xm", line)
    gui.Add("Text", "x10 y180 cBlue", "+ 30 ngày:")
    gui.Add("Text", "xm", line)
    gui.Add("Text", "x10 y220 cBlue", "+ 45 ngày:")
    gui.Add("Text", "xm", line)
    gui.Add("Text", "x10 y260 cBlue", "+ 60 ngày:")
    gui.Add("Text", "x10 y270 cBlue", "")
    gui.Add("Text", "x120 y20 cRed", "Ngày tính")
    gui.Add("Text", "x120 y60", FormatDate(DateAdd_Custom(baseDate, 4)))
    gui.Add("Text", "x120 y100", FormatDate(DateAdd_Custom(baseDate, 10)))
    gui.Add("Text", "x120 y140", FormatDate(DateAdd_Custom(baseDate, 14)))
    gui.Add("Text", "x120 y180", FormatDate(DateAdd_Custom(baseDate, 30)))
    gui.Add("Text", "x120 y220", FormatDate(DateAdd_Custom(baseDate, 45)))
    gui.Add("Text", "x120 y260", FormatDate(DateAdd_Custom(baseDate, 60)))
}

; DATE CYCLE CALCULATOR
^+e:: {
    dateStr := GetClipboardText()
    try {
        baseDate := DateParse(dateStr)
    } catch {
        baseDate := A_Now
    }
    ShowGuiWithEsc("Date Calculator", ShowDateCycleGuiBuilder.Bind(baseDate))
}

ShowDateCycleGuiBuilder(gui, baseDate) {
    line := "-------------------------------------------------------------------------"
    Loop 18 {
        if (A_Index = 1) {
            gui.Add("Text", "x10 y20 cRed", "Chu kỳ")
            gui.Add("Text", "x70 y20 cRed", "30 Ngày")
            gui.Add("Text", "x160 y20 cRed", "31 Ngày")
            gui.Add("Text", "xm", line)
        } else {
            if (A_Index = 18) {
                gui.Add("Text", "xm", "Hết hạn")
            } else {
                gui.Add("Text", "x10", A_Index - 1)
            }
            date30 := DateAdd_Custom(baseDate, 30 * (A_Index - 2))
            date31 := DateAdd_Custom(baseDate, 31 * (A_Index - 2))
            if (DateDiff__Custom(date30) > 0) {
                gui.Add("Text", "x70 yp cBlue", FormatDate(date30))
            } else {
                gui.Add("Text", "x70 yp", FormatDate(date30))
            }
            if (DateDiff__Custom(date31) > 0) {
                gui.Add("Text", "x160 yp cBlue", FormatDate(date31))
            } else {
                gui.Add("Text", "x160 yp", FormatDate(date31))
            }
            gui.Add("Text", "xm", line)
        }
    }
}

; CHECK PROFILE DT20
^+y:: {
    allowedProfiles := ["QT2", "TT2", "YT2", "RZT2", "SVT2", "TNT2", "WT2", "KT2", "TBT2", "Q263", "QTN1", "QTN2", "HAT2", "MCP", "SBK", "BKS", "ZMT", "DHMT", "ZHN", "W2G"]
    profile := GetClipboardText()
    isAllowed := ArrayIncludes(allowedProfiles, profile)
    ShowGuiWithEsc("Check DT20", ShowProfileCheckGuiBuilder.Bind(profile, isAllowed))
}

ShowProfileCheckGuiBuilder(gui, profile, isAllowed) {
    line := "-------------------------------------------------------------------------"
    gui.Add("Text", "x10 y20 cBlack", Format("Profile hiện tại là {1}", profile))
    if (isAllowed) {
        gui.Add("Text", "x130 y20 cBlue", "có thể đăng ký gói DT20")
    } else {
        gui.Add("Text", "x130 y20 cRed", "Không thể đăng ký gói DT20")
    }
    gui.Add("Text", "xm", line)
}

; CHECK CVTN AND GHLH
^+g:: {
    packagesCVTN := [
        "3MXH90", "6MXH90", "12MXH90", "3MXH100", "6MXH100", "12MXH100", "3MXH120", "6MXH120", "12MXH120", "3MXH150", "6MXH150", "12MXH150", "3MF159", "6MF159", "12MF159", "3KC120", "6KC120", "12KC120", "3KC150", "6KC150", "12KC150", "3NA70", "6NA70", "12NA70", "3NA90", "6NA90", "12NA90", "3NA120", "6NA120", "12NA120", "3S135", "6S135", "12S135", "3S159", "6S159", "12S159", "3MW90", "6MW90", "12MW90", "3MWG110", "6MWG110", "12MWG110", "3MWG125", "6MWG125", "12MWG125", "3MWG135", "6MWG135", "12MWG135", "3MWG155", "6MWG155", "12MWG155", "3MGX90", "6MGX90", "12MGX90", "3MGX110", "6MGX110", "12MGX110", "3MGX125", "6MGX125", "12MGX125", "3MAX90", "6MAX90", "12MAX90", "3V90", "6V90", "12V90", "3GX159", "6GX159", "12GX159", "3GX139", "6GX139", "12GX139", "MXH90", "MXH100", "MXH120", "MXH150", "MF159", "KC120", "KC150", "NA70", "NA90", "NA120", "S135", "S159", "MW90", "MWG110", "MWG125", "MWG135", "MWG155", "MGX90", "MGX110", "MGX125", "MAX90", "V90", "GX159", "GX139", "C120K", "12C120K", "MF219", "MF329", "3MF219", "6MF219", "12MF219", "3MF329", "6MF329", "12MF329", "3E300", "6E300", "12E300", "5GV", "5GC", "5GLQ", "3E500", "6E1000", "12E1000", "VZ100", "12VZ100", "VZ135", "12VZ135", "C90N", "3C90N", "6C90N", "12C90N", "3TK135", "6TK135", "12TK135", "TK135", 'KC90', '3KC90', '6KC90', '12KC90', '3TK159', '6TK159', '12TK159', 'TK159', '3PT90', '6PT90', '12PT90', 'PT90'
    ]
    packagesGHLH := {}
    packagesGHLH.KC90 := '12.000 đ' ;
    packagesGHLH.TK135 := '4.500 đ' ;
    packagesGHLH.C120 := '20.000 đ' ;
    packagesGHLH.C90 := '12.000 đ' ;
    packagesGHLH.C90N := '12.000 đ' ;
    packagesGHLH.KC120 := '16.000 đ' ;
    packagesGHLH.KC150 := '25.000 đ' ;
    packagesGHLH.PT120 := '10.000 đ' ;
    packagesGHLH.PT70 := '2.500 đ' ;
    packagesGHLH.PT90 := '3.000 đ' ;
    packagesGHLH.C120N := '16.000 đ' ;
    packagesGHLH.C120K := '28.000 đ' ;
    packagesGHLH.C120T := '28.000 đ' ;
    packagesGHLH.TK159 := '21.200 đ' ;
    packagesGHLH.TK219 := '29.200 đ' ;
    packagesGHLH.MXH80 := '6.000 đ' ;
    packagesGHLH.MXH90 := '6.000 đ' ;
    packagesGHLH.MXH100 := '7.000 đ' ;
    packagesGHLH.MXH120 := '20.000 đ' ;
    packagesGHLH.MXH150 := '30.000 đ' ;
    packagesGHLH.C50N := '40.000 đ' ;
    packagesGHLH.FD60 := '2.000 đ' ;
    packagesGHLH.21G := '4.000 đ'
    packagesGHLH.24G := '6.600 đ'
    packagesGHLH.12C120 := '120.000 đ'
    packagesGHLH.12C90N := '90.000 đ' ;
    packagesGHLH.12C50N := '50.000 đ' ;
    packagesGHLH.12KC150 := '150.000 đ' ;
    packagesGHLH.12KC120 := '120.000 đ' ;
    packagesGHLH.12KC90 := '90.000 đ' ;
    packagesGHLH.12PT120 := '120.000 đ' ;
    packagesGHLH.12PT90 := '90.000 đ' ;
    packagesGHLH.12PT70 := '70.000 đ' ;
    packagesGHLH.12MXH150 := '150.000 đ' ;
    packagesGHLH.12MXH120 := '120.000 đ' ;
    packagesGHLH.12MXH100 := '100.000 đ' ;
    packagesGHLH.12MXH90 := '90.000 đ' ;
    packagesGHLH.12MXH80 := '80.000 đ' ;
    packagesGHLH.12TK219 := '219.000 đ' ;
    packagesGHLH.12TK159 := '159.000 đ' ;
    packagesGHLH.12TK135 := '135.000 đ' ;
    packagesGHLH.NA70 := '7.000 đ' ;
    packagesGHLH.NA90 := '6.000 đ' ;
    packagesGHLH.NA120 := '6.000 đ' ;
    packagesGHLH.MBF30 := '10.000 đ' ;
    packagesGHLH.EDU100 := '10.000 đ' ;
    packagesGHLH.ME100 := '10.000 đ' ;
    packagesGHLH.AG90 := '5.000 đ' ;
    packagesGHLH.AG100 := '10.000 đ' ;
    packagesGHLH.GG135 := '5.000 đ' ;
    packagesGHLH.GG155 := '35.000 đ' ;
    packageClipboard := GetClipboardText()
    if !RegExMatch(packageClipboard, "^[a-zA-Z0-9]+$") {
        MsgBox Format("Gói cước '{1}' không hợp lệ", packageClipboard)
        return
    }
    resultCVTN := 0
    resultGHLH := 0
    for index, package in packagesCVTN {
        if package = packageClipboard {
            resultCVTN := 1
            break
        }
    }
    resultGHLH := loopkup(packagesGHLH, packageClipboard)
    ShowGuiWithEsc("Check CVTN and GHLH", ShowCVTNGHLHGuiBuilder.Bind(packageClipboard, resultCVTN, resultGHLH))
}

ShowCVTNGHLHGuiBuilder(gui, packageClipboard, resultCVTN, resultGHLH) {
    stringLine := "-------------------------------------------------------------------------"
    gui.Add("Text", "x10 y20 cRed", Format("Gói cước hiện tại là: '{1}'", packageClipboard))
    gui.Add("Text", "xm", stringLine)
    gui.Add("Text", "x10 y60 cBlue", "CVTN:")
    gui.Add("Text", "xm", stringLine)
    gui.Add("Text", "x10 y100 cBlue", "GHLH:")
    gui.Add("Text", "x10 y120 cBlue", "")
    if (resultCVTN = 1) {
        gui.Add("Text", "x100 y60 cBlack", "TRUE")
    } else {
        gui.Add("Text", "x100 y60 cBlack", "FALSE")
    }
    if (resultGHLH != 1) {
        gui.Add("Text", "x100 y100 cBlack", resultGHLH)
    } else {
        gui.Add("Text", "x100 y100 cBlack", resultCVTN)
    }
}

^+l:: {
    dataLS := {}
    dataLS.3GKK := 'MobiGold hòa mạng mới (do Mobi365 chuyển sang) / Mobi365 chuyển sang MobiGold: có chuyển tiền' ;
    dataLS.CFKK := 'MobiGold hòa mạng mới (do MobiCard chuyển sang) / Cắt MobiCard để chuyển sang MobiGold' ;
    dataLS.MCVU := 'MobiGold số công vụ hòa mạng mới (số mới)' ;
    dataLS.MS := 'MobiGold hòa mạng mới (số mới)' ;
    dataLS.QFON := 'MobiGold hòa mạng mới (do MobiQ chuyển sang)' ;
    dataLS.QTEF := 'MobiGold hòa mạng mới (do Q-Teen chuyển sang) / Q-Teen chuyển sang MobiGold' ;
    dataLS.SVFKK := 'MobiGold hòa mạng mới (do Q-Student chuyển sang) / Q-Student chuyển sang MobiGold' ;
    dataLS.UFKK := 'MobiGold hòa mạng mới (do Mobi4U chuyển sang) / Mobi4U chuyển sang MobiGold' ;
    dataLS.ZFKK := 'MobiGold hòa mạng mới (do MobiZone chuyển sang) / MobiZone chuyển sang MobiGold: Còn tiền' ;
    dataLS.CHS := 'Thay đổi thông tin do thông tin trước đó CH/ ĐLC cập nhật bị sai / Chặn 2 chiều do cửa hàng sau' ;
    dataLS.DTEN := '- Đổi tên cá nhân := cập nhật thêm tên cá nhân sau tên doanh nghiệp- Đổi tên doanh nghiệp := do doanh nghiệp đổi tên' ;
    dataLS.KHYC := 'Thay đổi dịch vụ do KHYC / Thay sim / Thay đổi giữa các hình thức trả trước KH tự chuyển / Chặn 2 chiều do khách hàng yêu cầu' ;
    dataLS.NTNC := 'Nhắn tin thông báo cước' ;
    dataLS.NTTB := 'Nhắn tin nhắc cước hay nhắn nội dung khác' ;
    dataLS.WARN := 'Nhắn tin nhắc cước hay nhắn tin báo đỏ' ;
    dataLS.PAID := 'Mở 2 chiều do thanh toán nợ cước' ;
    dataLS.PAID := 'Mở 1 chiều do KH thanh toán cước' ;
    dataLS.XMD := 'Mở 1 chiều do đã xác minh được địa chỉ thuê bao' ;
    dataLS.128K := 'Đổi sim qua sim dung lượng 128K' ;
    dataLS.CA64 := 'Đổi sim qua sim dung lượng 64K' ;
    dataLS.DSMP := 'Đổi sim miễn phí' ;
    dataLS.CCQ := 'Thuê bao được đấu mới do CCQ và chủ cũ đã thanh toán hết cước / Chặn 2 chiều do chuyển chủ quyền / Cắt hủy/ cắt hẳn MobiGold để chuyển chủ quyền và chủ cũ đã thanh toán hết cước' ;
    dataLS.CQC := 'Thuê bao được đấu mới do chuyển chủ quyền và KH mới đồng ý thanh toán cước của chủ cũ' ;
    dataLS.ANNI := 'Chặn 1 chiều / 2 chiều do yêu cầu từ Bộ Công An' ;
    dataLS.CA1 := 'Chặn 2 chiều do mất máy / Chặn 1 chiều do mất máy' ;
    dataLS.CA4 := 'Chặn 2 chiều do mất sim / Chặn 1 chiều do mất sim' ;
    dataLS.DEBT := 'Chặn 1 chiều / Chặn 2 chiều do nợ cước' ;
    dataLS.KHD := 'Chặn 1 chiều do không dùng/Chặn 2 chiều do KH yêu cầu tạm khóa' ;
    dataLS.KHDC := 'Chặn 1 chiều / Chặn 2 chiều do địa chỉ không có thực, giả mạo hồ sơ' ;
    dataLS.KNAI := 'Chặn 1 / 2 chiều do khách hàng khiếu nại' ;
    dataLS.KVMS := 'Tạm khóa 2 chiều - VMS' ;
    dataLS.KXD := 'Chặn 1 / 2 chiều do không xác minh được thông tin thuê bao' ;
    dataLS.QROI := 'Chặn 1 / 2 chiều do thuê bao quấy rối' ;
    dataLS.THLY := 'Chặn 2 chiều do khách hàng yêu cầu thanh lý hợp đồng' ;
    dataLS.XMB := 'Chặn 1 / 2 chiều do khách hàng cung cấp sai địa chỉ' ;
    dataLS.BADO := 'Chặn 1 chiều do TB sử dụng vượt quá mức cước ứng trước, báo đỏ' ;
    dataLS.HSO := 'Chặn 1 chiều do không có hồ sơ' ;
    dataLS.OTH := 'Chặn 1 chiều do các lý do khác' ;
    dataLS.CSKS := 'Chặn 1 chiều do nghi ngờ sim kích hoạt sẵn' ;
    dataLS.3FON := 'Mobi365 chuyển sang MobiGold: không còn tiền' ;
    dataLS.CA05 := 'Cắt hủy/ cắt hẳn MobiGold trong vòng 5 ngày tính từ ngày hòa mạng (đã bỏ nghiệp vụ này)' ;
    dataLS.CA2 := 'Cắt hủy/ cắt hẳn MobiGold do sóng yếu' ;
    dataLS.CA3 := 'Cắt hủy/ cắt hẳn MobiGold do KH hủy số không sử dụng; Cắt hủy/ cắt hẳn trả trước do KH hủy số không sử dụng' ;
    dataLS.CCNV := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang thuê bao nghiệp vụ' ;
    dataLS.CCVU := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang thuê bao công vụ' ;
    dataLS.CMCV := 'Chuyển máy công vụ' ;
    dataLS.CNV := 'Cắt hủy/ cắt hẳn MobiGold nghiệp vụ' ;
    dataLS.CTHU := 'Cắt hủy/ cắt hẳn MobiGold thuộc sim thử' ;
    dataLS.DEAC := 'Chặn 2 chiều do hết hạn nghe / Thuê bao trả trước bị cắt hủy/ delete do bị khóa 2 chiều quá hạn (hiện nay là 31 ngày)' ;
    dataLS.DPFC := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Fast Connect trả trước' ;
    dataLS.FONS := 'Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang SFONE' ;
    dataLS.FONV := 'Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang Viettel' ;
    dataLS.GOZO := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiZone' ;
    dataLS.HOSO := 'Cắt hủy/ cắt hẳn MobiGold do không có hồ sơ' ;
    dataLS.KKH := 'MobiGold chuyển sang MobiCard, không kích hoạt' ;
    dataLS.M365 := 'Mobi365 chuyển sang MobiGold' ;
    dataLS.MEZ := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiEZ' ;
    dataLS.MF4U := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Mobi4U' ;
    dataLS.MFQT := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Q-Teen' ;
    dataLS.MFSV := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Q-Student' ;
    dataLS.MGM3 := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang Mobi365' ;
    dataLS.MGMQ := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiQ' ;
    dataLS.MOBI := 'Cắt hủy/ cắt hẳn MobiGold để chuyển sang MobiCard' ;
    dataLS.NO2T := 'Cắt hủy/ cắt hẳn MobiGold do nợ cước quá' ;
    dataLS.QFKK := 'Cắt MobiQ để chuyển sang MobiGold' ;
    dataLS.SAIS := 'Cắt hủy/ cắt hẳn MobiGold do CH/ ĐLC đấu nối số sai qui định' ;
    dataLS.TK6T := 'Cắt hủy/ cắt hẳn MobiGold do thuê bao khóa 2 chiều quá 6 tháng (hiện nay là quá 31 ngày)' ;
    dataLS.VINA := 'Cắt hủy/ cắt hẳn MobiGold vì KH chuyển sang ViNaPhone' ;
    dataLS.DNTD := 'Đấu số trả trước mới (số mới - đấu nối tự động)' ;
    dataLS.DNFC := 'Đấu số MobiCard mới (do chuyển từ MobiGold sang)' ;
    dataLS.DNGQ := 'Đấu số MobiQ mới (do chuyển từ MobiGold sang)' ;
    dataLS.GLZO := 'MobiGold qua MobiZone' ;
    dataLS.FQTE := 'Chuyển MobiGold sang Q_TEEN' ;
    dataLS.DNQT := 'Chuyển MobiGold sang Mobi Qteen' ;
    dataLS.DNG3 := 'Chuyển MobiGold sang Mobi365' ;
    dataLS.DNFU := 'Chuyển MobiGold sang Mobi4U' ;
    dataLS.DNFSV := 'Chuyển MobiGold sang MobiQ_SV' ;
    dataLS.DN2S := 'Đấu nối Sim 2 số' ;
    dataLS.DNGD := 'Đấu nối hay khôi phục theo giấy duyệt' ;
    dataLS.DOIS := 'Đối soát' ;
    dataLS.HUY := 'Đấu F1 sửa sai TDN' ;
    dataLS.KP := 'Khôi phục số đã hủy' ;
    dataLS.VMS := 'Đấu mới' ;
    dataLS.STH := 'Sim Thu TT' ;
    dataLS.DNST := 'Đấu nối sim thử' ;
    dataLS.DBO := 'Thay đổi giữa các hình thức trả trước (do KH tự chuyển - bấm Note để xem chi tiết)' ;
    dataLS.QSV := 'Chuyển từ trả trước khác sang Q-SV' ;
    dataLS.QTE := 'Chuyển từ trả trước khác sang Q-Teen' ;
    dataLS.INAC := 'Chặn 1 chiều do hết hạn sử dụng (Mobi4U là do hết tiền)' ;
    dataLS.ACTI := 'Mở 2 chiều do nạp tiền / Kích hoạt số trả trước mới' ;
    dataLS.RES := 'Chặn 1 chiều do hết tiền (nhưng còn ngày sử dụng)' ;
    dataLS.CA7 := 'Hủy sim 2 số, thanh lý 1 số' ;
    dataLS.CKCVB := 'Chặn không chính chủ vùng biên, DTV xác minh ghi nhận code 19.19. Không xác minh được thì mời đến CHC' ;
    dataLS.SVBG := 'Spamcall-SVBG: ĐTV mời KH ra cửa hàng xác thực thông tin và làm cam kết để mở lại'
    key := GetClipboardText()
    MsgBox loopkup(dataLS, key)
}

;* Tong dai ung tien
^+u:: {
    codes := Map(
        "9015", Map("Time", "chờ 24h", "Tài khoản", "TKC", "Kiểm tra nợ", "KT", "DK ứng tự động", "UDT/SUBS", "Hủy ứng tự động", "HUY UTD", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "HU"),
        "9913", Map("Time", "", "Tài khoản", "TK_AP1: - Thoại/SMS nội mạng, liên mạng.", "Kiểm tra nợ", "", "DK ứng tự động", "TD", "Hủy ứng tự động", "HUY TD", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "UACHU"),
        "9928", Map("Time", "", "Tài khoản", "Phút gọi", "Kiểm tra nợ", "TT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "HT", "Mã hoàn ứng", "MBHU"),
        "9363", Map("Time", "", "Tài khoản", "KM3: Thoại/SMS nội mạng, liên mạng / DT20", "Kiểm tra nợ", "KT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "MBFHU"),
        "9070", Map("Time", "24h", "Tài khoản", "Data", "Kiểm tra nợ", "KT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "TT", "Mã hoàn ứng", "DT247HU"),
        "1256", Map("Time", "7 ngày", "Tài khoản", "TKC", "Kiểm tra nợ", "KT", "DK ứng tự động", "UDT", "Hủy ứng tự động", "HUY", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "EHU"),
        "1255", Map("Time", "", "Tài khoản", "TK_AP2: Thoại/SMS nội mạng, liên mạng.", "Kiểm tra nợ", "", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "", "Mã hoàn ứng", "UAGHU"),
        "5110", Map("Time", "", "Tài khoản", "Phút gọi", "Kiểm tra nợ", "KT", "DK ứng tự động", "", "Hủy ứng tự động", "", "Từ chối", "TC", "Chủ động hoàn ứng", "HT", "Mã hoàn ứng", "SPHU")
    )
    value := GetClipboardText()
    MsgBox GetInfoByCodeOrCompletionCode(codes, value)
}


^+j:: {
    seconds := GetClipboardText()
    seconds := Trim(seconds)
    hours := Floor(seconds / 3600)
    minutes := Floor(Mod(seconds, 3600) / 60)
    secs := Mod(seconds, 60)
    MsgBox Format("{1} Giờ {2} Phút {3} Giây", hours, minutes, secs)
}

^+k:: {
    kb := GetClipboardText()
    kb := Trim(kb)
    mb := Round(kb / 1024, 2)
    gb := Round(kb / 1024 / 1024, 2)
    result := Format("{1} MB, {2} GB", mb, gb)
    A_Clipboard := result
    MsgBox Format("Kích thước {1} KB tương đương với {2}", kb, result)
}

^Escape:: {
    if WinActive("ahk_class Package") || WinActive("ahk_class" "WindowsForms10.Window.8.app.0.1ca0192_r10_ad1")
        WinClose
}

^+d:: {
    agentRate := 0.159
    netRate := 0.127
    input := InputBox("Nhập giá gói cước", "Tính hoa hồng", "w150 h100")
    value := Trim(input.Value)
    if value {
        MsgBox Format("Hoa hồng đại lý: {1}`n`nHoa hồng thực nhận: {2}", Round(value * agentRate), Round(value * netRate))
    }
}

F1:: {
    Send "^1"
}
F2:: {
    Send "^2"
}
F3:: {
    Send "^3"
}
F4:: {
    Send "^4"
}

F5:: {
    Send "^r"
    Sleep 150
    Send "{Enter}"
}

DateAdd_Custom(date, days) {
    return DateAdd(date, days, "days")
}

FormatDate(date) {
    return FormatTime(date, "dd MMM yyyy")
}

DateDiff__Custom(date) {
    return DateDiff(A_Now, date, "days")
}

DateParse(str, americanOrder := 0) {
    ; Definition of several RegExes
    static monthNames := "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-zA-Z]*"
        , dayAndMonth := "(\d{1,2})[^a-zA-Z0-9:.]+(\d{1,2})"
        , dayAndMonthName := "(?:(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Day>\d{1,2})[^a-zA-Z0-9]+|(?<Day>\d{1,2})[^a-zA-Z0-9:.]*(?<Month>" . monthNames . "))"
        , monthNameAndYear := "(?<Month>" . monthNames . ")[^a-zA-Z0-9:.]*(?<Year>(?:\d{4}|\d{2}))"

    ampm := "am"
    if RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", &i) { ;ISO 8601 timestamps
        year := i.1, month := i.3, day := i.4, hour := i.5, minute := i.7, second := i.8
    }
    else if !RegExMatch(str, "^\W*(?<Hour>\d{1,2}+)(?<Minute>\d{2})\W*$", &t) { ; NOT timestring only eg 1535
        ; Try to extract the time parts
        FoundPos := RegExMatch(str, "i)(\d{1,2})"	;hours
            . "\s*:\s*(\d{1,2})"				;minutes
            . "(?:\s*:\s*(\d{1,2}))?"			;seconds
            . "(?:\s*([ap]m))?", &timepart)		;am/pm
        if (FoundPos) {
            ; Time is already parsed correctly from striing
            hour := timepart.1
            minute := timepart.2
            second := timepart.3
            ampm := timepart.4
            ; Remove time to parse the date part only
            str := StrReplace(str, timepart.0)
        }
        ; Now handle the remaining string without time and try to extract date ...
        if RegExMatch(str, "Ji)" . dayAndMonthName . "[^a-zA-Z0-9]*(?<Year>(?:\d{4}|\d{2}))?", &d) { ; named month eg 22May14; May 14, 2014; 22May, 2014
            year := d.Year, month := d.Month, day := d.Day
        }
        else if RegExMatch(str, "i)" . monthNameAndYear, &d) { ; named month and year without day eg May14; May 2014
            year := d.Year, month := d.Month
        }
        else if RegExMatch(str, "i)" . "^\W*(?<Year>\d{4})(?<Month>\d{2})\W*$", &d) { ;  month and year as digit only eg 201710
            year := d.Year, month := d.Month
        }
        else {
            ; Default values - if some parts are not given
            if ( not IsSet(day) and not IsSet(month) and not IsSet(year)) {
                ; No datepart is given - use today
                year := A_YYYY
                month := A_MM
                day := A_DD
            }
            if RegExMatch(str, "i)(\d{4})[^a-zA-Z0-9:.]+" . dayAndMonth, &d) { ;2004/22/03
                year := d.1, month := d.3, day := d.2
            }
            else if RegExMatch(str, "i)" . dayAndMonth . "(?:[^a-zA-Z0-9:.]+((?:\d{4}|\d{2})))?", &d) { ;22/03/2004 or 22/03/04
                year := d.3, month := d.2, day := d.1
            }
            if (RegExMatch(day, monthNames) or americanOrder and !RegExMatch(month, monthNames) or (month > 12 and day <= 12)) { ;try to infer day/month order
                tmp := month, month := day, day := tmp
            }
        }
    }
    else if RegExMatch(str, "^\W*(?<Hour>\d{1,2}+)(?<Minute>\d{2})\W*$", &timepart) { ; timestring only eg 1535
        hour := timepart.hour
        minute := timepart.minute
        ; Default values - if some parts are not given
        if ( not IsSet(day) and not IsSet(month) and not IsSet(year)) {
            ; No datepart is given - use today
            year := A_YYYY
            month := A_MM
            day := A_DD
        }
    }

    if (IsSet(day) or IsSet(month) or IsSet(year)) and not (IsSet(day) and IsSet(month) and IsSet(year)) { ; partial date
        if (IsSet(year) and not IsSet(month)) or not (IsSet(day) or IsSet(month)) or (IsSet(hour) and not IsSet(day)) { ; partial date must have month and day with time or day or year without time
            return
        }
    }

    ; Default values - if some parts are not given
    if (IsSet(year) and IsSet(month) and not IsSet(day)) {
        ; year and month given without day - use first day
        day := 1
    }

    ; Format the single parts
    oYear := (StrLen(year) == 2 ? "20" . year : (year))
    oYear := Format("{:02.0f}", oYear)

    if (isInteger(month)) {
        currMonthInt := month
    } else {
        currMonthInt := InStr(monthNames, SubStr(month, 1, 3)) // 4
    }
    ; Original: oMonth := ((month := month + 0 ? month : InStr(monthNames, SubStr(month, 1, 3)) // 4 ) > 0 ? month + 0.0 : A_MM)
    ; oMonth := ((month := month + 0 ? month : currMonthInt ) > 0 ? month + 0.0 : A_MM)
    ; oMonth := Format("{:02.0f}", oMonth)
    oMonth := Format("{:02.0f}", currMonthInt)

    oDay := day
    oDay := Format("{:02.0f}", oDay)

    if (IsSet(hour)) {
        if (hour != "") {
            oHour := hour + (hour == 12 ? ampm = "am" ? -12.0 : 0.0 : ampm = "pm" ? 12.0 : 0.0)
            oHour := Format("{:02.0f}", oHour)

            if (IsSet(minute)) {
                oMinute := minute + 0.0
                oMinute := Format("{:02.0f}", oMinute)

                if (IsSet(second)) {
                    if (second != "") {
                        oSecond := second + 0.0
                        oSecond := Format("{:02.0f}", oSecond)
                    }
                }
            }
        }
    }

    retVal := oYear . oMonth . oDay
    if (IsSet(oHour)) {
        retVal := retVal . oHour . oMinute
        if (IsSet(oSecond)) {
            retVal := retVal . oSecond
        }
    }
    return retVal
}

checkPhoneNumber(phoneNumber, filename) {
    filePath := Format("{1}\{2}", A_ScriptDir, filename)
    ; Read the file contents
    fileContents := FileRead(filePath)
    ; Split the file contents into lines
    lines := StrSplit(fileContents, "`n")

    ; Iterate over each line
    for line in lines
    {
        ; Split the line into columns
        columns := StrSplit(line, ",")
        ; Check if the phone number matches the first column
        if (columns[1] = phoneNumber)
        {
            ; Display the note from the second column
            return columns[2]
        }
    }

}

DisplayInfo(key, info) {
    infoStr := "Code: " key "`n"
    for k, v in info {
        infoStr .= k ": " v "`n"
    }
    return infoStr
}
GetInfoByCodeOrCompletionCode(codes, value) {
    if (codes.Has(value))
        return DisplayInfo(value, codes[value])


    for key, info in codes {
        if (info.Has("Mã hoàn ứng") && (info["Mã hoàn ứng"] = value))
            return DisplayInfo(key, info)

    }
}

loopkup(dataLS, key) {
    if dataLS.HasOwnProp(key) = 1 {
        return dataLS.GetOwnPropDesc(key).Value
    }
    else {
        return "Key not found"
    }
}