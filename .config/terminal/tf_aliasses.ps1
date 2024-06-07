Set-Alias -Name tf -Value terraform
function tff { tf fmt }
function tfv { tf validate }
function tfi { tf init }
function tfp { tf plan }
function tfa { tf apply }
function tfd { tf destroy }
function tfo { tf output }
function tfr { tf refresh }
function tfs { tf show }
function tfw { tf workspace }

function tffr { tff -recursive }
function tfip { tfi ; tfp }
function tfia { tfi ; tfa }
function tfid { tfi ; tfd }

function tfa! { tfa -auto-approve }
function tfia! { tfi ; tfa! }
function tfd! { tfd -auto-approve }
function tfid! { tfi ; tfd! }