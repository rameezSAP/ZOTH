CLASS ZCA_AB_DYNAMIC_GUI DEFINITION
 public
  create public .

  public section.
    types: begin of t_buttons,
             f01 type rsfunc_txt,
             f02 type rsfunc_txt,
             f03 type rsfunc_txt,
             f04 type rsfunc_txt,
             f05 type rsfunc_txt,
             f06 type rsfunc_txt,
             f07 type rsfunc_txt,
             f08 type rsfunc_txt,
             f09 type rsfunc_txt,
             f10 type rsfunc_txt,
             f11 type rsfunc_txt,
             f12 type rsfunc_txt,
             f13 type rsfunc_txt,
             f14 type rsfunc_txt,
             f15 type rsfunc_txt,
             f16 type rsfunc_txt,
             f17 type rsfunc_txt,
             f18 type rsfunc_txt,
             f19 type rsfunc_txt,
             f20 type rsfunc_txt,
             f21 type rsfunc_txt,
             f22 type rsfunc_txt,
             f23 type rsfunc_txt,
             f24 type rsfunc_txt,
             f25 type rsfunc_txt,
             f26 type rsfunc_txt,
             f27 type rsfunc_txt,
             f28 type rsfunc_txt,
             f29 type rsfunc_txt,
             f30 type rsfunc_txt,
             f31 type rsfunc_txt,
             f32 type rsfunc_txt,
             f33 type rsfunc_txt,
             f34 type rsfunc_txt,
             f35 type rsfunc_txt,
           end of t_buttons.
    types: begin of t_allowed_but,
             function type sy-ucomm,
           end of t_allowed_but.
    types: tt_excluded_but type standard table of sy-ucomm.
    types: tt_allowed_but type standard table of t_allowed_but.

    constants: b_save          type sy-ucomm value 'SAVE',
               b_back           type sy-ucomm value 'BACK',
               b_up            type sy-ucomm value 'UP',
               b_exit          type sy-ucomm value 'EXIT',
               b_print         type sy-ucomm value 'PRINT',
               b_find          type sy-ucomm value 'FIND',
               b_find_next     type sy-ucomm value 'FINDNEXT',
               b_first_page    type sy-ucomm value 'PGHOME',
               b_last_page     type sy-ucomm value 'PGEND',
               b_previous_page type sy-ucomm value 'PGUP',
               b_next_page     type sy-ucomm value 'PGDOWN',
               b_01            type sy-ucomm value 'F01',
               b_02            type sy-ucomm value 'F02',
               b_03            type sy-ucomm value 'F03',
               b_04            type sy-ucomm value 'F04',
               b_05            type sy-ucomm value 'F05',
               b_06            type sy-ucomm value 'F06',
               b_07            type sy-ucomm value 'F07',
               b_08            type sy-ucomm value 'F08',
               b_09            type sy-ucomm value 'F09',
               b_10            type sy-ucomm value 'F10',
               b_11            type sy-ucomm value 'F11',
               b_12            type sy-ucomm value 'F12',
               b_13            type sy-ucomm value 'F13',
               b_14            type sy-ucomm value 'F14',
               b_15            type sy-ucomm value 'F15',
               b_16            type sy-ucomm value 'F16',
               b_17            type sy-ucomm value 'F17',
               b_18            type sy-ucomm value 'F18',
               b_19            type sy-ucomm value 'F19',
               b_20            type sy-ucomm value 'F20',
               b_21            type sy-ucomm value 'F21',
               b_22            type sy-ucomm value 'F22',
               b_23            type sy-ucomm value 'F23',
               b_24            type sy-ucomm value 'F24',
               b_25            type sy-ucomm value 'F25',
               b_26            type sy-ucomm value 'F26',
               b_27            type sy-ucomm value 'F27',
               b_28            type sy-ucomm value 'F28',
               b_29            type sy-ucomm value 'F29',
               b_30            type sy-ucomm value 'F30',
               b_31            type sy-ucomm value 'F31',
               b_32            type sy-ucomm value 'F32',
               b_33            type sy-ucomm value 'F33',
               b_34            type sy-ucomm value 'F34',
               b_35            type sy-ucomm value 'F35',
               program_name    type progname value 'ZAB_DYNAMIC_GUI_STATUS'.

    class-data: allowed_buttons type tt_allowed_but.
    class-data: buttons type t_buttons.
    class-data: excluded_buttons type tt_excluded_but.
    class-methods: class_constructor.
    class-methods: add_button importing  value(iv_button)  type sy-ucomm
                                         value(iv_text)    type smp_dyntxt-text optional
                                         value(iv_icon)    type smp_dyntxt-icon_id optional
                                         value(iv_qinfo)   type smp_dyntxt-quickinfo optional
                                         value(iv_allowed) type abap_bool default abap_true
                              exceptions
                                         button_already_filled
                                         button_does_not_exists
                                         icon_and_text_empty.
    class-methods: hide_button importing value(iv_button) type sy-ucomm.
    class-methods: show_button importing value(iv_button) type sy-ucomm.
    class-methods: get_toolbar exporting e_toolbar type t_buttons.
    class-methods: add_separator importing  value(iv_button)  type sy-ucomm.
    class-methods: show_title  importing value(iv_text1) type string
                                         value(iv_text2) type string optional
                                         value(iv_text3) type string optional
                                         value(iv_text4) type string optional
                                         value(iv_text5) type string optional.
    class-methods: show_gui_status.
  protected section.
  private section.
endclass.



CLASS ZCA_AB_DYNAMIC_GUI IMPLEMENTATION.
method add_button.
    data button type smp_dyntxt.
    check iv_button is not initial.

    if iv_text is initial and iv_icon is initial.
      raise icon_and_text_empty.
      return.
    endif.

    button-icon_id = iv_icon.
    button-icon_text = iv_text.
    button-text      = iv_text.
    button-quickinfo = iv_qinfo.

    assign component iv_button of structure buttons to field-symbol(<bt>).
    if <bt> is assigned.
      if <bt> is initial.
        <bt> = button.
        if iv_allowed eq abap_true.
          show_button( iv_button = iv_button ).
        endif.
      else.
        raise button_already_filled.
      endif.
    else.
      raise button_does_not_exists.
    endif.
  endmethod.

  method add_separator.
    add_button(
      exporting
        iv_button              = iv_button
        iv_text                = |{ cl_abap_char_utilities=>minchar }|
*        iv_icon                = iv_icon
*        iv_qinfo               = iv_qinfo
         iv_allowed             = abap_true
      exceptions
        button_already_filled  = 1
        button_does_not_exists = 2
        icon_and_text_empty    = 3
        others                 = 4
    ).
    if sy-subrc <> 0.
*     message id sy-msgid type sy-msgty number sy-msgno
*                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endmethod.

  method class_constructor.
    excluded_buttons = value #( ( b_01 ) ( b_02 ) ( b_03 ) ( b_04 ) ( b_05 ) ( b_06 ) ( b_07 ) ( b_08 ) ( b_09 )
                                ( b_10 ) ( b_11 ) ( b_12 ) ( b_13 ) ( b_14 ) ( b_15 ) ( b_16 ) ( b_17 ) ( b_18 ) ( b_19 )
                                ( b_20 ) ( b_21 ) ( b_22 ) ( b_23 ) ( b_24 ) ( b_25 ) ( b_26 ) ( b_27 ) ( b_28 ) ( b_29 )
                                ( b_30 ) ( b_31 ) ( b_32 ) ( b_33 ) ( b_34 ) ( b_35 )
                                ( b_save ) ( b_find ) ( b_find_next ) ( b_first_page ) ( b_last_page ) ( b_next_page ) ( b_previous_page ) ( b_print ) ).
  endmethod.

  method get_toolbar.
    e_toolbar = buttons.
  endmethod.

  method hide_button.
    check iv_button is not initial.
    if line_exists( allowed_buttons[ function = iv_button ] ).
      delete allowed_buttons where function = iv_button.
      append iv_button to excluded_buttons.
    endif.
  endmethod.

  method show_button.
    check iv_button is not initial.
    if not line_exists( allowed_buttons[ function = iv_button ] ).
      data(allowed) = value t_allowed_but( function = iv_button ).
      append allowed to allowed_buttons.
      delete excluded_buttons where table_line eq iv_button.
    endif.
  endmethod.

  method show_gui_status.
    set pf-status 'DYNAMIC_STATUS' excluding excluded_buttons[] of program program_name.
  endmethod.

  method show_title.
    set titlebar 'DYNAMIC_TITLE' of program program_name with iv_text1 iv_text2 iv_text3 iv_text4 iv_text5.
  endmethod.
endclass.
