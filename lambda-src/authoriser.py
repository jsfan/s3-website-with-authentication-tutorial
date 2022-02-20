from base64 import b64encode
import re


def handler(event, context):
    realm = "My Password Protected Website"
    exp_user = 'someuser'  # TODO: Change to the username you want to use
    exp_pass = 'changeme'  # TODO: Change to the password you want to use
    exp_auth_string = b64encode(f'{exp_user}:{exp_pass}'.encode('ascii'))

    req = event['Records'][0]['cf']['request']
    headers = req['headers']

    auth_str = ""
    if headers.get('authorization') and len(headers['authorization']) and headers['authorization'][0]['value']:
        auth = re.split(r'\s+', headers['authorization'][0]['value'])
        if len(auth) > 1:
            auth_str = auth[1]

    response = {
        'body': 'Unauthorized',
        'bodyEncoding': 'text',
        'status': 401,
        'statusDescription': 'Unauthorized',
        'headers':
            {
                'www-authenticate': [
                    {
                        'key': 'WWW-Authenticate',
                        'value': 'Basic realm="' + realm + '"',
                    }
                ]
            }
    }

    if auth_str.encode('ascii') == exp_auth_string:
        return req

    return response
