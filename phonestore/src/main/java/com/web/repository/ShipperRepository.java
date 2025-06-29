package com.web.repository;

import com.web.entity.Shipper;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShipperRepository extends JpaRepository<Shipper, Long> {
    Shipper findShipperByUserId(Long id);
}
