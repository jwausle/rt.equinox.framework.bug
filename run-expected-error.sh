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
  -Dorg.osgi.framework.system.packages=javax.accessibility,javax.activation,javax.activity,javax.annotation.processing,javax.crypto,javax.crypto.interfaces,javax.crypto.spec,javax.imageio,javax.imageio.event,javax.imageio.metadata,javax.imageio.plugins.bmp,javax.imageio.plugins.jpeg,javax.imageio.spi,javax.imageio.stream,javax.jws,javax.jws.soap,javax.lang.model,javax.lang.model.element,javax.lang.model.type,javax.lang.model.util,javax.management,javax.management.loading,javax.management.modelmbean,javax.management.monitor,javax.management.openmbean,javax.management.relation,javax.management.remote,javax.management.remote.rmi,javax.management.timer,javax.naming,javax.naming.directory,javax.naming.event,javax.naming.ldap,javax.naming.spi,javax.net,javax.net.ssl,javax.print,javax.print.attribute,javax.print.attribute.standard,javax.print.event,javax.rmi,javax.rmi.CORBA,javax.rmi.ssl,javax.script,javax.security.auth,javax.security.auth.callback,javax.security.auth.kerberos,javax.security.auth.login,javax.security.auth.spi,javax.security.auth.x500,javax.security.cert,javax.security.sasl,javax.sound.midi,javax.sound.midi.spi,javax.sound.sampled,javax.sound.sampled.spi,javax.sql,javax.sql.rowset,javax.sql.rowset.serial,javax.sql.rowset.spi,javax.swing,javax.swing.border,javax.swing.colorchooser,javax.swing.event,javax.swing.filechooser,javax.swing.plaf,javax.swing.plaf.basic,javax.swing.plaf.metal,javax.swing.plaf.multi,javax.swing.plaf.nimbus,javax.swing.plaf.synth,javax.swing.table,javax.swing.text,javax.swing.text.html,javax.swing.text.html.parser,javax.swing.text.rtf,javax.swing.tree,javax.swing.undo,javax.tools,javax.transaction,javax.transaction.xa,javax.xml,javax.xml.bind,javax.xml.bind.annotation,javax.xml.bind.annotation.adapters,javax.xml.bind.attachment,javax.xml.bind.helpers,javax.xml.bind.util,javax.xml.crypto,javax.xml.crypto.dom,javax.xml.crypto.dsig,javax.xml.crypto.dsig.dom,javax.xml.crypto.dsig.keyinfo,javax.xml.crypto.dsig.spec,javax.xml.datatype,javax.xml.namespace,javax.xml.parsers,javax.xml.soap,javax.xml.stream,javax.xml.stream.events,javax.xml.stream.util,javax.xml.transform,javax.xml.transform.dom,javax.xml.transform.sax,javax.xml.transform.stax,javax.xml.transform.stream,javax.xml.validation,javax.xml.ws,javax.xml.ws.handler,javax.xml.ws.handler.soap,javax.xml.ws.http,javax.xml.ws.soap,javax.xml.ws.spi,javax.xml.ws.spi.http,javax.xml.ws.wsaddressing,javax.xml.xpath,org.ietf.jgss,org.omg.CORBA,org.omg.CORBA_2_3,org.omg.CORBA_2_3.portable,org.omg.CORBA.DynAnyPackage,org.omg.CORBA.ORBPackage,org.omg.CORBA.portable,org.omg.CORBA.TypeCodePackage,org.omg.CosNaming,org.omg.CosNaming.NamingContextExtPackage,org.omg.CosNaming.NamingContextPackage,org.omg.Dynamic,org.omg.DynamicAny,org.omg.DynamicAny.DynAnyFactoryPackage,org.omg.DynamicAny.DynAnyPackage,org.omg.IOP,org.omg.IOP.CodecFactoryPackage,org.omg.IOP.CodecPackage,org.omg.Messaging,org.omg.PortableInterceptor,org.omg.PortableInterceptor.ORBInitInfoPackage,org.omg.PortableServer,org.omg.PortableServer.CurrentPackage,org.omg.PortableServer.POAManagerPackage,org.omg.PortableServer.POAPackage,org.omg.PortableServer.portable,org.omg.PortableServer.ServantLocatorPackage,org.omg.SendingContext,org.omg.stub.java.rmi,org.w3c.dom,org.w3c.dom.bootstrap,org.w3c.dom.css,org.w3c.dom.events,org.w3c.dom.html,org.w3c.dom.ls,org.w3c.dom.ranges,org.w3c.dom.stylesheets,org.w3c.dom.traversal,org.w3c.dom.views,org.w3c.dom.xpath,org.xml.sax,org.xml.sax.ext,org.xml.sax.helpers \
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
