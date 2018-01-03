from logging.config import fileConfig
import os.path
import time
time.strptime("1970-01-01", "%Y-%m-%d")


fileConfig(r'/home/mapproxy/projects/demo_mapproxy/log.ini', {'log_file_suffix': time.strftime("%Y.%m.%d"),})

from mapproxy.multiapp import make_wsgi_app
application = make_wsgi_app(r'/data/web_projects/mapproxy/docker/projects', allow_listing=True)

