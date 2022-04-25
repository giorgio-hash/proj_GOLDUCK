checkAuth è il provider d'autorizzazione per la POST di /uploadfile.
l'instradamento checkAuth l'ho creato direttamente dalla Lambda.

OPTIONS è importante per la convalida della CORS mentre si effettua un upload in POST 
(vengono inviati due pacchetti separati, in parallelo)


il tipo di autorizzazione che ho scelto è l'autorizzazione Lambda semplice (booleana)

