# sp_depends_v2
Since MicroSoft will be retiring the existing sp_depends functionality, they have provided us with two dynamic management views to achieve the same. These two views are:
 - sys.dm_sql_referencing_entities
 - sys.dm_sql_referenced_entities
 
These two views contains more details than what's been provided by sp_depends. Hence I thought of creating a wrapper using these two views to return similar details.
 
Please feel free to enhance it in any possible way.
