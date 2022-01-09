package com.github.dk98126.codeqlproceduraldataflowapp.service;

import com.github.dk98126.codeqlproceduraldataflowapp.model.entity.PaperEntity;
import com.github.dk98126.codeqlproceduraldataflowapp.repository.PaperRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PaperService {
    private final PaperRepository paperRepository;

    public PaperEntity getById(Integer id) {
        return paperRepository.funGetPaper(id);
    }
}
