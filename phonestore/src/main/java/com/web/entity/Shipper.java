package com.web.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;

@Entity
@Table(name = "shipper")
@Getter
@Setter
public class Shipper {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;
    private String vehicleInfo;
    private Boolean available;
    @ManyToOne
    private User user;
}
