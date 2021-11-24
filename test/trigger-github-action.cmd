curl -X POST https://api.github.com/repos/timkimber/getssl/dispatches ^
-H "Accept: application/vnd.github.everest-preview+json" ^
-H "Authorization: token 66f265bae085c817a3b72bff1cabe4aa3e7ea31b" ^
--data "{\"event_type\": \"CUSTOM_ACTION_NAME_HERE\"}"
