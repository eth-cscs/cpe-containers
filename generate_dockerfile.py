import sys
import yaml

import jinja2

# first argument MUST be the path to the build_config.yaml file
# working directory MUST be the top-level directory of the repository,
# such that packages/*.yaml and Dockerfile.tmpl are found as relative paths

build_data = yaml.safe_load(open(sys.argv[1]))
cfg_path_components = sys.argv[1].split('/')
build_data['cpe_version'] = cfg_path_components[0]
build_data['architecture'] = cfg_path_components[1]
build_data['prgenv'] = cfg_path_components[2].removesuffix('.yaml').removesuffix('.yml')
package_list = []
for packages_path in build_data["packages"]:
    this_list = yaml.safe_load(open(packages_path))['pkgs']
    package_list += this_list
cpe_defaults_pkg = [x for x in package_list if x.startswith('cpe-defaults-')]
build_data['with_cpe_defaults_pkg'] = len(cpe_defaults_pkg)>0
build_data['packages'] = package_list
dockerfile = jinja2.Template(open('Dockerfile.tmpl').read()).render(build_data)
open('Dockerfile.rendered', 'w').write(dockerfile)
