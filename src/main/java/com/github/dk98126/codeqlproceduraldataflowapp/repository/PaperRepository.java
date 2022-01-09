package com.github.dk98126.codeqlproceduraldataflowapp.repository;

import com.github.dk98126.codeqlproceduraldataflowapp.model.entity.PaperEntity;
import org.springframework.data.jdbc.repository.query.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

public interface PaperRepository extends CrudRepository<PaperEntity, Integer> {

    @Query("SELECT * FROM F_GETPAPER(:id)")
    PaperEntity funGetPaper(@Param("id") Integer id);

}
