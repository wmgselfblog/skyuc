{include file="pageheader.tpl"}
<!-- start integrate setup form -->
<div style="border: 1px solid #CC0000;background-color:#FFFFCE;color:#CE0000;padding:4px;" >{$lang.uc_import_notice}</div>
<div class="main-div" style="padding:5px;">
  <form action="integrate.php" method="post" name="theForm">
  <h3>{$user_startid_intro}</h3>
  <h3>{$lang.uc_members_merge}</h3>
  <ul>
    <li style="list-style-type:none;"><input type="radio" name="merge" value="1" checked="checked" />{$lang.uc_members_merge_way1}</li>
    <li style="list-style-type:none;"><input type="radio" name="merge" value="2" />{$lang.uc_members_merge_way2}</li>
  </ul>
  <p id="SKYUC_NOTICE"></p>
  <input type="button" class="button"  value="{$lang.start_import}"  onclick="import_start(this)">
  </form>
</div>
<!-- end integrate setup form -->
{insert_scripts files="skyuc_validator.js"}
{literal}
<script language="JavaScript">
<!--
function import_start(obj)
{
  var frm = document.forms['theForm'];
  var merge = -1;
  for (var i=0; i<frm.elements['merge'].length; i++)
  {
    if (frm.elements['merge'][i].checked)
    {
      merge = frm.elements['merge'][i].value;
    }
  }
  if (merge < 0)
  {
    alert(no_method);
    return;
  }

  var notice = document.getElementById('SKYUC_NOTICE');
  notice.innerHTML = user_importing;
  obj.disabled = true;
  Ajax.call('integrate.php?act=import_user', 'start=0&merge=' + merge, checkResponse, 'GET', 'JSON');
}

function checkResponse(result)
{
  if (result.error > 0)
  {
    alert(result.message);
  }
  if (result.error == 0)
  {
    var notice = document.getElementById('SKYUC_NOTICE');
    notice.innerHTML = result.message;
    window.setTimeout(function ()
    {
        location.href='integrate.php?act=complete';
    }, 1000);
  }
}
//-->
</script>
{/literal}
{include file="pagefooter.tpl"}
