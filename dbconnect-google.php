<?php
try{
$pdo = new pdo('mysql:unix_socket=/cloudsql/silver-fiber-89210:gpslocation;dbname=gpstracker',
  'root',  // username
  ''       // password
  );}

catch(PDOException $e)
{
print "ERROR".$e->getMessage();

echo "db error";
}

echo "db connection done";
?>