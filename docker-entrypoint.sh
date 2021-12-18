#!/bin/sh

set -e

sphinx-autobuild sphinx_wiki sphinx_wiki_html --port 8000 --host 0.0.0.0
