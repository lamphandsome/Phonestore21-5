package com.web.config;

import com.web.jwt.JWTConfigurer;
import com.web.jwt.JwtTokenProvider;
import com.web.repository.UserRepository;
import com.web.serviceImp.UserServiceDetail;
import com.web.serviceImp.UserServiceImp;
import com.web.utils.Contains;
import com.web.utils.UserUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.BeanIds;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;

@EnableWebSecurity
@Configuration
@EnableGlobalMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    private final JwtTokenProvider tokenProvider;

    private final UserRepository userRepository;

    private final CorsFilter corsFilter;

    public WebSecurityConfig(JwtTokenProvider tokenProvider, UserRepository userRepository, CorsFilter corsFilter) {
        this.tokenProvider = tokenProvider;
        this.userRepository = userRepository;
        this.corsFilter = corsFilter;
    }

    @Bean(BeanIds.AUTHENTICATION_MANAGER)
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        // Get AuthenticationManager bean
        return super.authenticationManagerBean();
    }

    @Autowired
    UserServiceDetail userServiceDetail;


    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userServiceDetail).passwordEncoder(passwordEncoder());
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .csrf().disable()
                .addFilterBefore(corsFilter, UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling()
                .and()
                .headers()
                .and()
                .authorizeRequests()
                .antMatchers(
                        "/css/**",
                        "/js/**",
                        "/images/**",
                        "/image/**",
                        "/webjars/**",
                        "/static/**",
                        "/vendor/**",
                        "/fonts/**",
                        "/favicon.ico"
                ).permitAll()
                .antMatchers("/api/*/public/**", "/api/login", "/api/regis","/dangnhap","/","/product**","/detail**","/giohang**"/*,"/timdonhang**"*/,"/chitietbaiviet**","/baiviet**","/index**","/dangky","/xacnhan","/api/active-account").permitAll()
                .antMatchers("/api/*/user/**").hasAuthority(Contains.ROLE_USER)
                .antMatchers("/api/admin/check-role-admin").hasAuthority(Contains.ROLE_ADMIN)
                .antMatchers("/api/*/employee/**").hasAuthority(Contains.ROLE_EMPLOYEE)
                .antMatchers("/shipper**", "/shipper").hasAuthority(Contains.ROLE_SHIPPER)
                .antMatchers("/api/*/admin/**").hasAnyAuthority(Contains.ROLE_ADMIN, Contains.ROLE_EMPLOYEE)
                .anyRequest().authenticated()
                .and()
                .apply(securityConfigurerAdapter()); // ✅ chỉ gọi 1 lần ở cuối
    }


    private JWTConfigurer securityConfigurerAdapter() {
        return new JWTConfigurer(tokenProvider, userRepository);
    }

}

