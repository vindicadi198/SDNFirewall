CREATE TABLE blocked(
    network varchar(16) NOT NULL,
    prefix_length numeric(2) NOT NULL,
    protocol char(1) NOT NULL,
    port int NOT NULL,
    PRIMARY KEY(network,prefix_length,protocol,port),
    CHECK (protocol in ('T','U')),
    CHECK (port>=1 AND port<=65536),
    CHECK (prefix_length>=0 AND prefix_length<=32)
);
