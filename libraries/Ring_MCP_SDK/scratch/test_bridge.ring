# اختبار إرسال واستقبال القياسي (Stdio) والتأكد من عدم وجود Blocking

fputs(stderr, "=== Test Started ===" + nl)

# محاكاة إرسال رد وهمي
cResponse = '{"id":1,"jsonrpc":"2.0","result":{"capabilities":{},"protocolVersion":"2024-11-05","serverInfo":{"name":"TestServer","version":"1.0"}}}'

fputs(stderr, "Writing to stdout..." + nl)
fputs(stdout, cResponse + nl)

# إجبار الـ Buffer على الإفراغ
fputs(stderr, "Flushing stdout..." + nl)
fflush(stdout)

fputs(stderr, "=== Test Finished ===" + nl)
