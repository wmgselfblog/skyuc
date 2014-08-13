<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>{$lang.cp_home}{if $ur_here} - {$ur_here}{/if}</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="styles/general.css" rel="stylesheet" type="text/css" />
<link href="styles/main.css" rel="stylesheet" type="text/css" />

<style type="text/css">
  body {
    color: white;
  }
</style>

{insert_scripts files="../skyuc_utils.js,skyuc_validator.js"}
<script language="JavaScript">
<!--
// 这里把JS用到的所有语言都赋值到这里
{foreach from=$lang.js_languages key=key item=item}
var {$key} = "{$item}";
{/foreach}
//-->
</script>

</head>
<body style="background: #278296">

{if $form_act eq "forget_pwd"}
<form action="get_password.php" method="post" name="submitAdmin" onsubmit="return validate()">
  <table cellspacing="0" cellpadding="0" style="margin-top: 100px" align="center">
  <tr>
    <td><img src="images/login.gif" width="178" height="256" border="0" alt="SKYUC PHP" /></td>
    <td style="padding-left: 50px">
      <table>
        <tr>
          <td colspan="2"><h3>{$lang.get_newpassword}</h3></td>
        </tr>
        <tr>
          <td>{$lang.user_name}</td>
          <td>
            <input type="text"  name="user_name" maxlength="20" size="30"/>{$lang.require_field}
          </td>
        </tr>
        <tr>
          <td>{$lang.email}</td>
          <td>
            <input type="text"  name="email" size="30" />{$lang.require_field}
         </td>
        </tr>
       <tr>
         <td>&nbsp;</td>
         <td>
           <input type="hidden" name="action" value="get_pwd" />
           <input type="hidden" name="act" value="forget_pwd" />
           <input type="submit" class="button primary submitButton" value="{$lang.click_button}"  />
           <input type="reset" class="button submitButton"  value="{$lang.reset_button}"  />
         </td>
       </tr>
      </table>
    </td>
  </tr>
  </table>
</form>
{/if}
{if $form_act eq "reset_pwd"}
<form action="get_password.php" method="post" name="submitPwd" onsubmit="return validate2()">
  <table cellspacing="0" cellpadding="0" style="margin-top: 100px" align="center">
  <tr>
    <td><img src="images/login.gif" width="178" height="256" border="0" alt="SKYUC PHP" /></td>
    <td style="padding-left: 50px">
      <table>
        <tr>
          <td colspan="2"><h3>{$lang.get_newpassword}</h3></td>
        </tr>
        <tr>
          <td>{$lang.enter_admin_pwd}</td>
          <td>
            <input type="password" name="password" size="30"/>{$lang.require_field}
          </td>
        </tr>
        <tr>
          <td>{$lang.confirm_admin_pwd}</td>
          <td>
            <input type="password" name="confirm_pwd" size="30" />{$lang.require_field}
         </td>
        </tr>
       <tr>
         <td>&nbsp;</td>
         <td>
           <input type="hidden" name="action" value="reset_pwd" />
           <input type="hidden" name="act" value="forget_pwd" />
           <input type="hidden" name="adminid" value="{$adminid}" />
           <input type="hidden" name="code" value="{$code}" />
           <input type="submit" class="button primary submitButton" value="{$lang.click_button}"  />
           <input type="reset" class="button submitButton"  value="{$lang.reset_button}"  />
         </td>
       </tr>
      </table>
    </td>
  </tr>
  </table>
</form>
{/if}

<script type="text/javascript">
<!--
/**
* 检查表单输入的数据
*/
function validate()
{
  validator = new Validator("submitAdmin");
  validator.required("user_name", user_name_empty);
  validator.required("email", email_empty, 1);
  validator.isEmail("email", email_error);

  return validator.passed();
}

function validate2()
{
  validator = new Validator("submitPwd");
  validator.required("password",            admin_pwd_empty);
  validator.required("confirm_pwd",         confirm_pwd_empty);
  if (document.forms['submitPwd'].elements['confirm_pwd'].value.length > 0)
  {
    validator.eqaul("password","confirm_pwd", both_pwd_error);
  }

  return validator.passed();
}
//-->
</script>

</body>
</html>
