package com.web.config;


import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.unit.DataSize;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.*;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;


import javax.servlet.MultipartConfigElement;
import java.util.Locale;


@Configuration
public class WebConfig extends WebMvcConfigurerAdapter {


    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**").allowedOrigins("*")
                .allowCredentials(false)
                .allowedOriginPatterns("http://*","https://*")
                .allowedMethods("*")
                .allowedHeaders("*")
                .maxAge(1800).exposedHeaders("Authorization,Link,X-Total-Count,X-${jhipster.clientApp.name}-alert,X-${jhipster.clientApp.name}-error,X-${jhipster.clientApp.name}-params");


    }


    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("/resources/");
    }


    @Bean
    public MultipartConfigElement multipartConfigElement() {
        MultipartConfigFactory factory = new MultipartConfigFactory();
        factory.setMaxFileSize(DataSize.ofBytes(1000000000L));
        factory.setMaxRequestSize(DataSize.ofBytes(1000000000L));
        return factory.createMultipartConfig();
    }
    @Bean
    public LocaleResolver localeResolver() {
        SessionLocaleResolver slr = new SessionLocaleResolver();
        slr.setDefaultLocale(new Locale("vi", "VN")); // Đặt Locale mặc định là tiếng Việt
        return slr;
    }


    @Bean
    public LocaleChangeInterceptor localeChangeInterceptor() {
        LocaleChangeInterceptor lci = new LocaleChangeInterceptor();
        lci.setParamName("lang"); // Bạn có thể thay đổi locale bằng cách thêm ?lang=en hoặc ?lang=vi vào URL
        return lci;
    }


    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(localeChangeInterceptor());
    }




}
