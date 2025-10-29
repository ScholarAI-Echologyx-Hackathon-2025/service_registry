package org.solace.scholar_ai.service_registry;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

/**
 * Main entry point for the ScholarAI Service Registry.
 * 
 * This is our central service discovery server using Netflix Eureka.
 * All microservices register here so they can find each other.
 */
@SpringBootApplication
@EnableEurekaServer
public class ServiceRegistryApplication {

	private static final Logger log = LoggerFactory.getLogger(ServiceRegistryApplication.class);

	public static void main(String[] args) {
		ConfigurableApplicationContext context = SpringApplication.run(ServiceRegistryApplication.class, args);
		Environment env = context.getEnvironment();
		
		String port = env.getProperty("server.port", "8761");
		String profile = env.getProperty("spring.profiles.active", "default");
		
		log.info("\n----------------------------------------------------------\n\t" +
				"Service Registry is running!\n\t" +
				"Profile(s): \t{}\n\t" +
				"Dashboard: \thttp://localhost:{}\n" +
				"----------------------------------------------------------",
				profile, port);
	}

}
