
if ! javac -version | grep '11.' ; then
  echo "No javac-11 is on the path. Change it and try again." ; exit 1;
fi

# javac+jar force.javax.annotation.usage.jar
build_bundle () {
  javac -d $(pwd)/force.javax.annotation.usage/bin \
     -classpath \
:$(pwd)/eclipse/plugins/org.eclipse.osgi_3.12.100.v20180210-1608.jar\
:$(pwd)/eclipse/plugins/org.eclipse.e4.core.di_1.6.100.v20170421-1418.jar\
     -g -nowarn \
     -target 11 \
     -source 11 \
     -encoding UTF-8 \
     $(find $(pwd)/force.javax.annotation.usage/src -type f | xargs echo | sed 's/ / /g')
  cd force.javax.annotation.usage/bin
  jar cfm ../force.javax.annotation.usage.jar ../META-INF/MANIFEST.MF .
  cd ../..
}

# make eclipse/config.ini
make_conf () {
  FILE=$1
  touch ${FILE}
  echo "osgi.bundles=\
reference\:file\:/$(pwd)/eclipse/plugins/javax.inject_1.0.0.v20091030.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/javax.servlet_3.1.0.v201410161800.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/javax.transaction_1.1.1.v201105210645.jar,\
reference\:file\:/$(pwd)/eclipse/plugins/javax.xml_1.3.4.v201005080400.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.apache.felix.gogo.runtime_0.10.0.v201209301036.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.apache.felix.gogo.shell_0.10.0.v201212101605.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.e4.core.di.annotations_1.6.0.v20170119-2002.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.e4.core.di.extensions_0.15.0.v20170228-1728.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.e4.core.di_1.6.100.v20170421-1418.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.equinox.console_1.1.300.v20170512-2111.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.equinox.region_1.4.0.v20170117-1425.jar,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.equinox.transforms.hook_1.2.0.v20170105-1446.jar,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.equinox.weaving.hook_1.2.0.v20160929-1449.jar,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.osgi.compatibility.state_1.1.0.v20170516-1513.jar,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.osgi.services_3.6.0.v20170228-1906.jar@start,\
reference\:file\:/$(pwd)/eclipse/plugins/org.eclipse.osgi.util_3.4.0.v20170111-1608.jar@start,\
reference\:file\:/$(pwd)/force.javax.annotation.usage/force.javax.annotation.usage.jar@start"    >> ${FILE}
  echo "osgi.install.area=file:$(pwd)/eclipse/" >> ${FILE}
  echo "osgi.bundles.defaultStartLevel=4"       >> ${FILE}
  echo "osgi.framework=file:$(pwd)/eclipse/plugins/org.eclipse.osgi_3.12.100.v20180210-1608.jar" >> ${FILE}
  echo "osgi.configuration.cascaded=false"      >> ${FILE}
}

if ! find . | grep force.javax.annotation.usage.jar ; then
  build_bundle
fi

CONF_DIR=eclipse/configutation
if ! ls ${CONF_DIR}/config.ini ; then
  mkdir -p ${CONF_DIR}
  make_conf ${CONF_DIR}/config.ini
fi

java \
  -Declipse.ignoreApp=true \
  -Dorg.osgi.framework.system.capabilities="osgi.ee; osgi.ee=\"JavaSE\";version:List=\"1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,11\", osgi.ee; osgi.ee=\"OSGi/Minimum\";version:List=\"1.0,1.1,1.2\"" \
  -classpath $(pwd)/eclipse/plugins/org.eclipse.equinox.launcher_1.4.0.v20161219-1356.jar \
  org.eclipse.equinox.launcher.Main \
  -configuration ${CONF_DIR} \
  -os macosx \
  -ws cocoa \
  -arch x86_64 \
  -nl de_DE \
  -consoleLog \
  -console \
  -noExit
