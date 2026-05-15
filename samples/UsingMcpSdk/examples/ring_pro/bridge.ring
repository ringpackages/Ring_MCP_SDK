load "mcp.ring"

# إعداد الـ HTTP Client
load "libcurl.ring"
Url = "http://localhost:3000/mcp"

# حلقة الاستماع لـ Antigravity
cBuffer = ""
while true
    if feof(stdin) bye ok
    cLine = ""
    give cLine
    if len(cLine) = 0 
        if feof(stdin) bye ok
        if cBuffer = "" loop ok
    ok
    
    cBuffer += cLine + nl
    
    try
        aMsg = json_decode(cBuffer)
        cBuffer = "" # اكتمل الطلب
        
        # إرسال الطلب للسيرفر عبر الويب
        curl = curl_easy_init()
        curl_easy_setopt(curl, CURLOPT_URL, Url)
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, mcp_json_encode(aMsg))
        cResponse = curl_easy_perform_silent(curl)
        
        # إرسال الرد القادم من الويب إلى Antigravity
        if cResponse != NULL
            fputs(stdout, cResponse + nl)
        ok
        curl_easy_cleanup(curl)
        
    catch
        loop
    done
end
