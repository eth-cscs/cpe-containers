import sys
import yaml

import jinja2

all_configs = []
for cfg_path in sys.argv[1:]:
    cfg_path_components = cfg_path.split('/')
    cfg = {}
    cfg['path'] = cfg_path
    cfg['name'] = cfg_path.removesuffix('.yaml').removesuffix('.yml')
    cfg['cpe_version'] = cfg_path_components[0]
    cfg['architecture'] = cfg_path_components[1]
    cfg['prgenv'] = cfg_path_components[2].removesuffix('.yaml').removesuffix('.yml')
    all_configs.append(cfg)

ci_pipeline = jinja2.Template(open('ci/cpe.yml.tmpl').read()).render({'configs': all_configs})
open('generated_pipeline.yml', 'w').write(ci_pipeline)
