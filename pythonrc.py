import os
import sys
from pprint import pprint

try:
    from ptpython.repl import embed as _embed
except ImportError:
    print("ptpython is not available: falling back to standard prompt")
else:
    sys.exit(
        _embed(
            globals(),
            locals(),
            vi_mode=True,
            history_filename=os.environ.get(
                "PYTHON_HISTORY", os.path.expanduser("~/.python_history")
            ),
        )
    )
