package com.example.springdemo.controller;

import java.nio.charset.Charset;

// import org.opensearch.client.base.RestClientTransport;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sagemakerruntime.SageMakerRuntimeClient;
import software.amazon.awssdk.services.sagemakerruntime.model.InvokeEndpointRequest;
import software.amazon.awssdk.services.sagemakerruntime.model.InvokeEndpointResponse;

@RestController
@RequestMapping("/")
public class DemoController {
    @GetMapping(value = "health", produces = MediaType.APPLICATION_JSON_VALUE)
    public String healthCheck() {
        // RestClientTransport t;
        return "{\"status\":\"ok!\"}";
    }

    @PostMapping(value = "chat", produces = MediaType.APPLICATION_JSON_VALUE)
    public String chat(@RequestBody String postStr) {
        String endpointName = "chatglm2";

        Region region = Region.US_EAST_1;

        SageMakerRuntimeClient runtimeClient = SageMakerRuntimeClient.builder()
                .region(region)
                .build();

        // String payload = "{\"instances\": [{\"data\": " + postStr + "}]}";

        // System.out.println(payload);

        return invokeSpecficEndpoint(
                runtimeClient,
                endpointName,
                postStr,
                "application/json");
    }

    private String invokeSpecficEndpoint(
            SageMakerRuntimeClient runtimeClient,
            String endpointName, String payload,
            String contentType) {

        InvokeEndpointRequest endpointRequest = InvokeEndpointRequest.builder()
                .endpointName(endpointName)
                .contentType(contentType)
                .body(SdkBytes.fromString(payload, Charset.defaultCharset()))
                .build();

        InvokeEndpointResponse response = runtimeClient.invokeEndpoint(endpointRequest);
        return response.body().asString(Charset.defaultCharset());
    }
}
