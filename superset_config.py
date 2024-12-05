from authenticator.dataflowsupersetauthenticator import CustomSecurityManager
from flask_appbuilder.security.manager import AUTH_DB
import os
import configparser

BASE_PATH=f"/user/{os.environ.get('HOSTNAME').split('-')[1]}/proxy/8088"
AUTH_USER_REGISTRATION = True
SECRET_KEY = '4sGcJSyy/+znLLJBKu57VxxaKL5PxVL84uECDQbj4Tt+/M1sfybyHY09'
AUTH_TYPE = AUTH_DB
CUSTOM_SECURITY_MANAGER = CustomSecurityManager

WTF_CSRF_ENABLED = False
HTTP_HEADERS={'X-Frame-Options':'ALLOWALL'}
# Use all X-Forwarded headers when ENABLE_PROXY_FIX is True.
# When proxying to a different port, set "x_port" to 0 to avoid downstream issues.
ENABLE_PROXY_FIX = True
PROXY_FIX_CONFIG = {"x_for": 1, "x_proto": 2, "x_host": 1, "x_port": 0, "x_prefix": 1}
STATIC_ASSETS_PREFIX = BASE_PATH
APP_ICON = f"{BASE_PATH}/static/assets/images/superset-logo-horiz.png"

# Do you want Talisman enabled?
TALISMAN_ENABLED = False
AUTH_ROLE_PUBLIC='Public'
PUBLIC_ROLE_LIKE='Gamma'
SUPERSET_LOAD_EXAMPLES="yes"
PREFERRED_URL_SCHEME = 'https'

config_parser = configparser.ConfigParser()
ui_config = config_parser.read('/dataflow/app/config/dataflow.cfg')
REDIS_URL = config_parser.get('redis', 'redis_url')


CACHE_CONFIG = {
    'CACHE_TYPE': 'redis',
    'CACHE_DEFAULT_TIMEOUT': 86400,
    'CACHE_KEY_PREFIX': 'superset_results',
    'CACHE_REDIS_URL': f"{REDIS_URL}"
}

class CeleryConfig:  # pylint: disable=too-few-public-methods
    broker_url = f"{REDIS_URL}"
    result_backend = f"{REDIS_URL}"

CELERY_CONFIG: type[CeleryConfig] = CeleryConfig

THEME_OVERRIDES = {
    'borderRadius': 4,
    'colors': {
        'primary': {
            'light1': '#e3e8e8',  # $primaryLight
            'base': '#3fb0ac',     # $primaryMain
            'dark1': '#14383d',    # $primaryDark
            'light2': '#8b9fa1',   # $primary200
            'dark2': '#0d282c',    # $primary800
        },
        'secondary': {
            'light1': '#e8f6f5',   # $secondaryLight
            'base': '#3fb0ac',     # $secondaryMain
            'dark1': '#39a9a5',    # $secondaryDark
            'light2': '#9fd8d6',   # $secondary200
            'dark2': '#299792',    # $secondary800
        },
        'success': {
            'light1': '#b9f6ca',   # $successLight
            'base': '#00e676',     # $successMain
            'dark1': '#00c853',    # $successDark
            'light2': '#69f0ae',   # $success200
        },
        'error': {
            'light1': '#ef9a9a',   # $errorLight
            'base': '#f44336',     # $errorMain
            'dark1': '#c62828',    # $errorDark
        },
        'warning': {
            'light1': '#fff8e1',   # $warningLight
            'base': '#ffe57f',     # $warningMain
            'dark1': '#ffc107',    # $warningDark
        },
        'grayscale': {            'light1': '#f8fafc',   # $grey50
            'light2': '#eef2f6',   # $grey100
            'light3': '#e3e8ef',   # $grey200
            'base': '#697586',     # $grey500
            'dark1': '#4b5565',    # $grey600
            'dark2': '#364152',    # $grey700
            'dark3': '#121926',    # $grey900
        },
        'info': {
            'base': '#30baba',     # $blue500
        },
        'selected': {
            'base': '#bbe8e8',     # $selected
        },
    }
}