package com.web.serviceImp;

import com.web.entity.User;
import com.web.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
@Service
public class UserServiceDetail implements UserDetailsService {
    @Autowired
    UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username).get();
        List<GrantedAuthority> roles = new ArrayList<>();
        GrantedAuthority role = new GrantedAuthority() {
            @Override
            public String getAuthority() {
                return user.getAuthorities().getName();
            }
        };
        roles.add(role);
        return new org.springframework.security.core.userdetails.User(username, user.getPassword(), roles);
    }
}
