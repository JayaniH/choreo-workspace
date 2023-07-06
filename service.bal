import ballerina/http;
import ballerina/regex;

type WifiPayload readonly & record {|
    string username;
    string email;
    string password;
|};

type WifiPayloadRecord record {|
    readonly string email;
    WifiPayload[] wifiAccounts;
|};

table<WifiPayloadRecord> key(email) wifiAccounts = table [
    {email: "nadheesh@wso2.com", wifiAccounts: [{email: "nadheesh@wso2.com", username: "newuser", password: "newpass"}]},
    {email: "malithj@wso2.com", wifiAccounts: [{email: "malithj@wso2.com", username: "malith", password: "malithpass"}]}
];

service / on new http:Listener(9090) {

    # Get the wifi accounts of a given user
    resource function get guest\-wifi\-accounts/[string ownerEmail]() returns string[] {
        string[] payload = [];
        if (!wifiAccounts.hasKey(ownerEmail)) {
            return payload;
        }
        WifiPayloadRecord wifiRecords = wifiAccounts.get(ownerEmail);
        foreach WifiPayload wifiAccount in wifiRecords.wifiAccounts {
            if (wifiAccount.email == ownerEmail) {
                payload.push(string `${wifiAccount.username}.guestOf.${regex:split(ownerEmail, "@")[0]}`);
            }
        }
        return payload;
    }

    # Add a new wifi account
    resource function post guest\-wifi\-accounts(@http:Payload WifiPayload wifiRecord) returns string {

        if !(wifiAccounts.hasKey(wifiRecord.email)) {
            wifiAccounts.add({email: wifiRecord.email, wifiAccounts: [wifiRecord]});
        } else {
            WifiPayloadRecord wifiRecords = wifiAccounts.get(wifiRecord.email);
            wifiRecords.wifiAccounts.push(wifiRecord);
        }
        return "Successfully added the wifi account";
    }
}
