{include file="pageheader.tpl"}
<div class="main-div">
  <form action="ad_position.php" method="post" name="theForm" enctype="multipart/form-data" onsubmit="return validate()">
    <table width="100%">
      <tr>
        <td class="label">{$lang.position_name}</td>
        <td><input type="text" name="position_name" value="{$posit_arr.position_name}" size="30" /></td>
      </tr>
      <tr>
        <td class="label">{$lang.ad_width}</td>
        <td><input type="text" name="ad_width" value="{$posit_arr.ad_width}" size="30" /> {$lang.unit_px}</td>
      </tr>
      <tr>
        <td class="label">{$lang.ad_height}</td>
        <td>
          <input type="text" name="ad_height" value="{$posit_arr.ad_height}" size="30" /> {$lang.unit_px}
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.position_desc}</td>
        <td>
          <input type="text" name="position_desc" size="55" value="{$posit_arr.position_desc}" />
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.posit_style}</td>
        <td>
          <textarea class="textCtrl" name="position_style" cols="55" rows="6">{$posit_arr.position_style}</textarea>
        </td>
      </tr>
      <tr>
        <td class="label">&nbsp;</td>
        <td>
          <input type="submit" class="button primary submitButton" value="{$lang.button_submit}"  />
          <input type="reset" class="button submitButton"  value="{$lang.button_reset}"  />
        </td>
      </tr>
     <tr>
       <td colspan="2">
         <input type="hidden" name="act" value="{$form_act}" />
         <input type="hidden" name="id" value="{$posit_arr.position_id}" />
       </td>
     </tr>
    </table>
  </form>
</div>
{insert_scripts files="skyuc_validator.js"}
<script language="JavaScript">
<!--

document.forms['theForm'].elements['position_name'].focus();
/**
 * 检查表单输入的数据
 */
function validate()
{
    validator = new Validator("theForm");
    validator.required("position_name",   posit_name_empty);
    validator.required("ad_width",        ad_width_empty);
    validator.required("ad_height",       ad_height_empty);
    validator.isNumber("ad_width",        ad_width_number, true);
    validator.isNumber("ad_height",       ad_height_number, true);
    validator.required("position_style",  empty_position_style);

    if (document.forms['theForm'].elements['ad_width'].value > 1024 || document.forms['theForm'].elements['ad_width'].value == 0)
    {
        alert(width_value);
        return false;
    }
    if (document.forms['theForm'].elements['ad_height'].value > 1024 || document.forms['theForm'].elements['ad_height'].value == 0)
    {
        alert(height_value);
        return false;
    }

    return validator.passed();
}
//-->

</script>
{include file="pagefooter.tpl"}
