package com.github.dk98126.codeqlproceduraldataflowapp.model.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@AllArgsConstructor
@Table("PAPERS")
public class PaperEntity {
    @Id
    private Integer paperId;
    private String title;
    @Column("ABSTRACT")
    private String anAbstract;
    private String authors;
}
