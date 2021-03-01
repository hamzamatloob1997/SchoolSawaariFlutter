import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:school_sawaari_app/components/custom_surfix_icon.dart';
import 'package:school_sawaari_app/components/default_button.dart';
import 'package:school_sawaari_app/components/form_error.dart';
import 'package:school_sawaari_app/constants.dart';
import 'package:school_sawaari_app/size_config.dart';
import 'package:school_sawaari_app/widgets/loading_alert_dailog.dart';
import 'package:school_sawaari_app/widgets/snack_bar.dart';

class ParentEditProfile extends StatefulWidget {
  static String routeName = "/parent_edit_profile";

  @override
  _ParentEditProfileState createState() => _ParentEditProfileState();
}

class _ParentEditProfileState extends State<ParentEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];

  String storeName;
  String storeCnic;
  String storeAddress;
  String storePhoneNo;

  String name;
  String cnic;
  String address;
  String phoneNo;

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Color(0XFF8B8B8B),
          ),
        ),
        elevation: 2,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Parents')
            .doc(FirebaseAuth.instance.currentUser.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data == null)
            return SpinKitCircle(
              color: kPrimaryColor,
            );
          storeName = snapshot.data['Name'];
          storeCnic = snapshot.data['CNIC'];
          storePhoneNo = snapshot.data['PhoneNo'];
          storeAddress = snapshot.data['Address'];
          return SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(20)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    child: Column(
                      children: [
                        SizedBox(height: SizeConfig.screenHeight * 0.03),
                        Text(
                          "You can edit your profile here!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildNameFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildCNICFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildPhoneNumberFormField(),
                        SizedBox(height: getProportionateScreenHeight(30)),
                        buildAddressFormField(),
                        SizedBox(height: getProportionateScreenHeight(40)),
                        FormError(errors: errors),
                        SizedBox(height: getProportionateScreenHeight(20)),
                        DefaultButton(
                          text: "Update",
                          press: () async {
                            if (_formKey.currentState.validate()) {
                              if (name == null) {
                                name = storeName;
                              }
                              if (address == null) {
                                address = storeAddress;
                              }
                              if (phoneNo == null) {
                                phoneNo = storePhoneNo;
                              }
                              if (cnic == null) {
                                cnic = storeCnic;
                              }
                              showLoadingDialog(context);
                              try {
                                await FirebaseFirestore.instance
                                    .collection('Parents')
                                    .doc(
                                        FirebaseAuth.instance.currentUser.email)
                                    .update({
                                  'Name': name,
                                  'CNIC': cnic,
                                  'Address': address,
                                  'PhoneNo': phoneNo,
                                }).then((value) => {
                                  Navigator.pop(context),
                                  Snack_Bar.show(context, "Profile Updated Successfully!")
                                });
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  TextFormField buildAddressFormField() {
    return TextFormField(
      initialValue: storeAddress,
      keyboardType: TextInputType.streetAddress,
      onSaved: (newValue) => address = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kAddressNullError);
          address = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kAddressNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Address",
        hintText: "Enter your Home address",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon:
            CustomSurffixIcon(svgIcon: "assets/icons/Location point.svg"),
      ),
    );
  }

  TextFormField buildPhoneNumberFormField() {
    return TextFormField(
      initialValue: storePhoneNo,
      maxLength: 13,
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneNo = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
          phoneNo = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Phone Number",
        hintText: "Enter your phone number",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildCNICFormField() {
    return TextFormField(
      initialValue: storeCnic,
      keyboardType: TextInputType.number,
      maxLength: 13,
      onSaved: (newValue) => cnic = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kCNICError);
          cnic = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kCNICError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "CNIC",
        hintText: "Enter your CNIC",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/card.svg"),
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      initialValue: storeName,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNamelNullError);
          name = value;
        }
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kNamelNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Name",
        hintText: "Enter your name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}