package com.github.dk98126.codeqlproceduraldataflowapp.controller;

import com.github.dk98126.codeqlproceduraldataflowapp.model.entity.PaperEntity;
import com.github.dk98126.codeqlproceduraldataflowapp.service.PaperService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/paper")
public class PaperController {

    private final PaperService paperService;

    @GetMapping("/{id}")
    public ResponseEntity<PaperEntity> getPaperById(@PathVariable Integer id) {
        return ResponseEntity.ok(paperService.getById(id));
    }

}
