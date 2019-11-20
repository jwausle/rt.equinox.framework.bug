# Eclipse bug1: rt.equinox.framework.bug

 1. 'Unresolved requirement: Require-Capability: osgi.ee; filter:="(&(osgi.ee=JavaSE)(version=11))'
 2. 'NoClassDefFoundError: javax/annotation/PostConstruct' while using of 'InjectorFactory.getDefault()' (java11 only)

## What's happen?
During usage of `InjectorFactory.getDefault()` raise an `NoClassDefFoundError: javax/annotation/PostConstruct` despite successful wired `javax.annotation` package at `org.eclipse.e4.core.di` - exported from `org.eclipse.osgi-3.12.100`.

## Environment?
- java11;vendor=oracle
- org.eclipse.osgi;version=3.12.100
- org.eclipse.e4.core.di;version=1.6.100

## Full stacktrace?

```
Root exception:
org.eclipse.e4.core.di.InjectionException: java.lang.NoClassDefFoundError: javax/annotation/PostConstruct
	at org.eclipse.e4.core.internal.di.InjectorImpl.inject(InjectorImpl.java:93)
	at force.javax.annotation.usage.Activator.start(Activator.java:15)
	at org.eclipse.osgi.internal.framework.BundleContextImpl$3.run(BundleContextImpl.java:779)
	at org.eclipse.osgi.internal.framework.BundleContextImpl$3.run(BundleContextImpl.java:1)
	at java.base/java.security.AccessController.doPrivileged(Native Method)
	at org.eclipse.osgi.internal.framework.BundleContextImpl.startActivator(BundleContextImpl.java:772)
	at org.eclipse.osgi.internal.framework.BundleContextImpl.start(BundleContextImpl.java:729)
	at org.eclipse.osgi.internal.framework.EquinoxBundle.startWorker0(EquinoxBundle.java:933)
	at org.eclipse.osgi.internal.framework.EquinoxBundle$EquinoxModule.startWorker(EquinoxBundle.java:309)
	at org.eclipse.osgi.container.Module.doStart(Module.java:581)
	at org.eclipse.osgi.container.Module.start(Module.java:449)
	at org.eclipse.osgi.container.ModuleContainer$ContainerStartLevel.incStartLevel(ModuleContainer.java:1634)
	at org.eclipse.osgi.container.ModuleContainer$ContainerStartLevel.incStartLevel(ModuleContainer.java:1614)
	at org.eclipse.osgi.container.ModuleContainer$ContainerStartLevel.doContainerStartLevel(ModuleContainer.java:1585)
	at org.eclipse.osgi.container.ModuleContainer$ContainerStartLevel.dispatchEvent(ModuleContainer.java:1528)
	at org.eclipse.osgi.container.ModuleContainer$ContainerStartLevel.dispatchEvent(ModuleContainer.java:1)
	at org.eclipse.osgi.framework.eventmgr.EventManager.dispatchEvent(EventManager.java:230)
	at org.eclipse.osgi.framework.eventmgr.EventManager$EventThread.run(EventManager.java:340)
Caused by: java.lang.NoClassDefFoundError: javax/annotation/PostConstruct
	at org.eclipse.e4.core.internal.di.InjectorImpl.inject(InjectorImpl.java:124)
	at org.eclipse.e4.core.internal.di.InjectorImpl.inject(InjectorImpl.java:91)
	... 17 more
Caused by: java.lang.ClassNotFoundException: javax.annotation.PostConstruct cannot be found by org.eclipse.e4.core.di_1.6.100.v20170421-1418
	at org.eclipse.osgi.internal.loader.BundleLoader.findClassInternal(BundleLoader.java:433)
	at org.eclipse.osgi.internal.loader.BundleLoader.findClass(BundleLoader.java:395)
	at org.eclipse.osgi.internal.loader.BundleLoader.findClass(BundleLoader.java:387)
	at org.eclipse.osgi.internal.loader.ModuleClassLoader.loadClass(ModuleClassLoader.java:150)
	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:521)
	... 19 more
```

## Howto reproduce?
- I share a [github repo](https://github.com/jwausle/rt.equinox.framework.bug)
- `run-error.sh` to raise the exception
- `run-quickfix.sh` to show my quickfix solution

## Quickfix:
- setup the runtime parameter `-Dorg.osgi.framework.system.packages=without,javax.annotation,package`
- to overwrite calculated system packages from [JavaSE-9.profile](https://github.com/eclipse/rt.equinox.framework/blob/master/bundles/org.eclipse.osgi/JavaSE-9.profile)

## My investigations:
I guess `org.eclipse.osgi-3.12.100` is still not ready to run with java11
- `org.eclipse.osgi` still export `javax.annotation` package in version "0.0.0"
- but this `javax.annotation` package not longer exist in java11 ([described here](https://docs.oracle.com/en/java/javase/11/migrate/index.html#JSMIG-GUID-F640FA9D-FB66-4D85-AD2B-D931174C09A3))
- it's part of removed module  `java.xml.ws.annotation`
- and it seems that equinox wire this NOT-EXISTING-PACKAGE to bundles who import this one (e.g. 'org.eclipse.e4.core.di')

## My peace of code to enforce the error.

```
// activation code.
package force.javax.annotation.usage;

import org.eclipse.e4.core.di.InjectorFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

@SuppressWarnings("restriction")
public class Activator implements BundleActivator {

	public void start(BundleContext bundleContext) throws Exception {
		InjectorFactory.getDefault();
	}

	public void stop(BundleContext bundleContext) throws Exception {
	}
}

```
