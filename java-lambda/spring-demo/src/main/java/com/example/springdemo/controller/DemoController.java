package com.example.springdemo.controller;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/")
public class DemoController {
    @GetMapping(value="health", produces = MediaType.APPLICATION_JSON_VALUE)
    public String healthCheck() {
        return "{\"status\":\"ok!\"}";
    }
}
