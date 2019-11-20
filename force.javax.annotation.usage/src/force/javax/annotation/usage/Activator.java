package force.javax.annotation.usage;

import org.eclipse.e4.core.di.IInjector;
import org.eclipse.e4.core.di.InjectorFactory;
import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

@SuppressWarnings("restriction")
public class Activator implements BundleActivator {

	public void start(BundleContext bundleContext) throws Exception {
		IInjector default1 = InjectorFactory.getDefault();
		default1.inject(new Object(), null);
	}

	public void stop(BundleContext bundleContext) throws Exception {
	}
}
