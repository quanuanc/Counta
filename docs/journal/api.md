request: get /journal_page?page=1&order=desc
param:
- page：必需，页码（1 开始）。超过总页数会返回 404。每页大小固定 1000 条
- order：必需，排序方向；仅当值为 "asc" 时升序，否则一律按降序处理（等价于 "desc"）。

response: ./response.json
