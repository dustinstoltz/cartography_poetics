
# -----------------------------------------------------------------------------
# Figure 2. Immigrant and Citizen to Cultural Dimensions
# -----------------------------------------------------------------------------

    years <- seq(1810, 2000, by=10)

    search.imm <- c("immigrants", "immigrant", "immigration")
    search.cit <- c("citizens", "citizenship", "citizen")

    # -------------------------------------------------------------------------  
    # CREATE RACE DIMENSION
    dims <- df.anchors %>% filter(relation=="racial" & in_embeddings==TRUE)
    # i = 1
    df.a <- data.frame(matrix(nrow=length(years), ncol=3))
    colnames(df.a) <- c("Immigration", "Citizenship", "Year")

    for(i in 1:length(years) ){
        wv     <- hi.wv[[i]]
        s.wv.imm <- CMDist::get_centroid(search.imm, wv)
        s.wv.cit <- CMDist::get_centroid(search.cit, wv)
        s.wv   <- rbind(s.wv.imm, s.wv.cit)
        d.wv   <- CMDist::get_direction(dims[,1:2], wv)
        r.imm  <- sim2(x = d.wv, y = s.wv, 
                       method = "cosine", norm = "l2")
        df.a[i,] <- cbind(r.imm, years[i]) 
        }

    df.a$Dimension <- "Race"

    # -------------------------------------------------------------------------  
    # CREATE CLASS DIMENSION
    dims <- df.anchors %>% filter(relation=="affluence" & in_embeddings==TRUE)

    df.b <- data.frame(matrix(nrow=length(years), ncol=3))
    colnames(df.b) <- c("Immigration", "Citizenship", "Year")

    for(i in 1:length(years) ){
        wv     <- hi.wv[[i]]
        s.wv.imm <- CMDist::get_centroid(search.imm, wv)
        s.wv.cit <- CMDist::get_centroid(search.cit, wv)
        s.wv   <- rbind(s.wv.imm, s.wv.cit)
        d.wv   <- CMDist::get_direction(dims[,1:2], wv)
        r.imm  <- sim2(x = d.wv, y = s.wv, 
                       method = "cosine", norm = "l2")
        df.b[i,] <- cbind(r.imm, years[i]) 
        }

    df.b$Dimension <- "Affluence"

    # -------------------------------------------------------------------------
    # CREATE MORALITY DIMENSION
    dims <- df.anchors %>% filter(relation=="morality" & in_embeddings==TRUE)

    df.c <- data.frame(matrix(nrow=length(years), ncol=3))
    colnames(df.c) <- c("Immigration", "Citizenship", "Year")

    for(i in 1:length(years) ){
        wv     <- hi.wv[[i]]
        s.wv.imm <- CMDist::get_centroid(search.imm, wv)
        s.wv.cit <- CMDist::get_centroid(search.cit, wv)
        s.wv   <- rbind(s.wv.imm, s.wv.cit)
        d.wv   <- CMDist::get_direction(dims[,1:2], wv)
        r.imm  <- sim2(x = d.wv, y = s.wv, 
                       method = "cosine", norm = "l2")
        df.c[i,] <- cbind(r.imm, years[i]) 
        }

    df.c$Dimension <- "Morality"

# -----------------------------------------------------------------------------
# Merge Datasets
# -----------------------------------------------------------------------------

    df.all <- bind_rows(
        melt(df.a, id.vars=c("Year", "Dimension") ),
        melt(df.b, id.vars=c("Year", "Dimension") ),
        melt(df.c, id.vars=c("Year", "Dimension") )
    )

    colnames(df.all) <- c("year", "dimension", "term", "similarity")
    # colnames(df.all)

# -----------------------------------------------------------------------------
#  Semantic Direction PLOTS
# -----------------------------------------------------------------------------

    p.imm.line <- 
        df.all %>%
        filter(year >= 1880 &
               dimension == "Race" | dimension == "Affluence") %>% 
        dcast(year + term  ~ dimension, value.var = "similarity") %>%
        ggplot(aes(x = Affluence, y = Race, group = term)) +
        geom_point(aes(color = term, shape = term),  size=2.5) +
        geom_text_repel(aes(label=year, hjust=.002) ) +
        ylab("Race Dimension ('White' to 'Black')") +
        xlab("Affluence Dimension ('Low Class' to 'High Class')") +
        labs(subtitle = "Race and Affluence Dimensions")

    p.imm.mor.line <- 
        df.all %>%
        filter(year >= 1880 &
               dimension == "Race" | dimension == "Morality") %>% 
        dcast(year + term  ~ dimension, value.var = "similarity") %>%
        ggplot(aes(x = Morality, y = Race, group = term)) +
        geom_point(aes(color = term, shape = term),  size=2.5) +
        geom_text_repel(aes(label = year, hjust=.002) ) +
        ylab("Race Dimension ('White' to 'Black')") +
        xlab("Morality Dimension ('Bad' to 'Good')") +
        labs(subtitle = "Race and Morality Dimensions")

    png("fig2_immigr_race_affluence_morals_dims_plot.png", 
        width =11, height = 5, units = 'in', res = 200)
    ggarrange(p.imm.line, p.imm.mor.line)
    dev.off()

# -----------------------------------------------------------------------------
# THE END
# -----------------------------------------------------------------------------
