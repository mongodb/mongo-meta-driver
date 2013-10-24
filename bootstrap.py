# this is a wrapper to make the docs site work

import imp
import os

os.chdir(os.path.join(os.getcwd(), 'docs'))
docs_bootstrap = imp.load_source('bootstrap', os.path.join(os.getcwd(), 'bootstrap.py'))
docs_bootstrap.main()
