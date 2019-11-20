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