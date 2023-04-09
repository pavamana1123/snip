const fs = require('fs');
const {google} = require('googleapis');
var credentials = JSON.parse(fs.readFileSync('./credentials.json'))
var token = JSON.parse(fs.readFileSync('./sheets-token.json'))
const {client_secret, client_id, redirect_uris, scriptId} = credentials.installed.sheets;

const auth = new google.auth.OAuth2(client_id, client_secret, redirect_uris[0]);
auth.setCredentials(token);

client = google.script({version: 'v1', auth});

client.scripts.run({
    resource: {
        function: "listPendingSnippets",
    },
    scriptId,
}, function(scriptError, scriptResponse) {
    if (scriptError) throw scriptError
    if (scriptResponse.error) throw scriptResponse.error
    if (scriptResponse.data.error) throw scriptResponse.data.error

    fs.writeFileSync("./snippet-status.json",JSON.stringify(scriptResponse.data.response.result))
});