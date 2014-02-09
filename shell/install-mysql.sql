use mysql;
UPDATE user SET host = '%' WHERE host='precise64' AND user="root";
flush privileges;