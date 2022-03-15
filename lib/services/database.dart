import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:medicine/models/historyModel.dart';
import 'package:medicine/models/pharmacyModel.dart';
import 'package:medicine/models/medicineModel.dart';
import 'package:medicine/models/userModel.dart';

class Database {
  static CurrUser? _currUser;
  static Pharmacy? _currPharmacy;
  static bool isPharmacist = false;
  static var _subCollectionRef;
  static var _medicineSubCollectionRef;

  static final _popularMedicineRef =
      FirebaseFirestore.instance.collection('PopularMedicine');

  static List<SearchHistory> _searchHistory = [];

  static List<Medicine> _medicine = [];

  static List<PopularMedicine> _popular = [];

  static setCurrUser(CurrUser currUser) {
    _currUser = currUser;
  }

  static CurrUser? getCurrUser() {
    return _currUser;
  }

  List<SearchHistory> getSearchHistory() {
    return _searchHistory;
  }

  static setUserSubCollectionRef(String currUserID) {
    _subCollectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currUserID)
        .collection("Search History");
  }

  static Future<String> createUser(CurrUser _user) async {
    String retVal = "error";

    try {
      await FirebaseFirestore.instance.collection('Users').doc(_user.uid).set(
        {
          'fullName': _user.fullName,
          'email': _user.email,
          'uid': _user.uid,
          'createdOn': _user.dateCreated,
          'telephone': _user.tele,
          'accType': _user.accType,
          'imgURL': _user.imgURL,
          'isPharmacist': _user.isPharmacist,
          'pharmacyId': ""
        },
      );
      retVal = "success";
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    return retVal;
  }

  static Future<Map> getUserDoc(String currUserID) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currUserID)
        .get();

    var data = snap.data() as Map;
    CurrUser user = CurrUser.fromJson(data);
    Database.setCurrUser(user);
    return data;
  }

  static addSearchHistory(String medicine, String searchedBy) async {
    String docId = _subCollectionRef.doc().id;

    try {
      _subCollectionRef.doc(docId).set({
        'id': docId,
        'name': medicine,
        'searchedOn': Timestamp.now(),
        'searchedBy': searchedBy,
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static updatePopularMedicineCollection(String medicine) async {
    var t = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var date = formatter.format(t);
    print(date);

    try {
      var snap =
          await _popularMedicineRef.where('name', isEqualTo: medicine).get();

      if (snap.size > 0) {
        String docID = snap.docs[0].id;
        await _popularMedicineRef
            .doc(docID)
            .update({'search counter': FieldValue.increment(1)});

        await _popularMedicineRef
            .doc(docID)
            .collection("dates")
            .doc(date)
            .get()
            .then((value) => {
                  if (value.exists)
                    {
                      _popularMedicineRef
                          .doc(docID)
                          .collection("dates")
                          .doc(date)
                          .update({'search counter': FieldValue.increment(1)})
                    }
                  else
                    {
                      _popularMedicineRef
                          .doc(docID)
                          .collection("dates")
                          .doc(date)
                          .set({
                        'date': t,
                        'name': medicine,
                        'search counter': FieldValue.increment(1)
                      })
                    }
                });
      } else {
        _popularMedicineRef.add({
          'name': medicine,
          'search counter': FieldValue.increment(1)
        }).then((value) => {
              _popularMedicineRef
                  .doc(value.id)
                  .collection("dates")
                  .doc(date)
                  .set({
                'search counter': FieldValue.increment(1),
                'date': t,
                'name': medicine
              })
            });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future getUserHistory() async {
    var q =
        await _subCollectionRef.orderBy('searchedOn', descending: true).get();

    if (q.size > 0) {
      //Convert query result to a list to loop through them
      List results = q.docs.map((e) => e.data()).toList();

      //First check if the list is empty or not before converting
      //results to dart models
      if (_searchHistory.isNotEmpty) {
        _searchHistory.clear();
      }
      results.forEach((element) {
        //Convert list of results to model dart models
        SearchHistory r = SearchHistory.fromJson(element);
        _searchHistory.add(r);
      });
      return "Success";
    } else {
      return "Failure";
    }
  }

  Future deleteSearchHistory(String id) async {
    try {
      _subCollectionRef.doc(id).delete();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future deleteAllSearchHistory() async {
    await _subCollectionRef.get().then((collection) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in collection.docs) {
        batch.delete(doc.reference);
      }
      return batch.commit();
    });
  }

  /* 
    Pharmacist Database Functions are below
  */

  static Future<Map> getPharmacyDoc(String pharmacyID) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('Pharmacies')
        .doc(pharmacyID)
        .get();

    var data = snap.data() as Map;
    Pharmacy user = Pharmacy.fromJson(data);
    Database.setCurrPharmacy(user);
    Database.setPharmacySubCollectionRef(user.id);
    return data;
  }

  static void setCurrPharmacy(Pharmacy user) {
    _currPharmacy = user;
  }

  static Pharmacy? getCurrPharmacy() {
    return _currPharmacy;
  }

  static List<Medicine> getMedicineList() {
    return _medicine;
  }

  static List<PopularMedicine> getPopularList() {
    return _popular;
  }

  static setPharmacySubCollectionRef(String currPharmacyID) {
    _medicineSubCollectionRef = FirebaseFirestore.instance
        .collection('Pharmacies')
        .doc(currPharmacyID)
        .collection('medicine');
  }

  static Future getMedicineFromFirestore() async {
    var q = await _medicineSubCollectionRef
        .orderBy('generic name', descending: false)
        .get();

    if (q.size > 0) {
      //Convert query result to a list to loop through them
      List results = q.docs.map((e) => e.data()).toList();

      //First check if the list is empty or not before converting
      //results to dart models
      if (_medicine.isNotEmpty) {
        _medicine.clear();
      }
      results.forEach((element) {
        //Convert list of results to model dart models
        Medicine r = Medicine.fromJson(element);
        _medicine.add(r);
      });
      return "Success";
    } else {
      return "Failure";
    }
  }

  static Future deleteMedcineDoc(String id) async {
    try {
      await _medicineSubCollectionRef.doc(id).delete();
      Fluttertoast.showToast(msg: "Medicine deleted successfully!");

      //Update local list
      _medicine.removeWhere((element) => element.id == id);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static Future getPopularMedicineCollection() async {
    var q = await _popularMedicineRef
        .orderBy("search counter", descending: true)
        .get();
    if (q.size > 0) {
      //Convert query result to a list to loop through them
      List results = q.docs.map((e) => e.data()).toList();

      //First check if the list is empty or not before converting
      //results to dart models
      if (_popular.isNotEmpty) {
        _popular.clear();
      }
      results.forEach((element) {
        //Convert list of results to model dart models
        PopularMedicine r = PopularMedicine.fromJson(element);
        _popular.add(r);
      });
      return "Success";
    } else {
      return "Failure";
    }
  }

  static Future updateMedicineDoc({
    required Medicine? medicine,
    required int localListIndex,
    required List<bool> operation,
    List? removedBrandNames,
    required List brandList,
  }) async {
    try {
      await _medicineSubCollectionRef.doc(medicine!.id).get().then((value) {
        if (value["generic name"] == medicine.name &&
            value["inStock"] == medicine.inStock &&
            value["brand names"] == medicine.brandNames &&
            value["desc"] == medicine.desc) {
          Fluttertoast.showToast(
              msg: "Updated Failed! No changes to document.");
          return "Error";
        }
        if (value["generic name"] != medicine.name) {
          _medicineSubCollectionRef.doc(medicine.id).update(
            {
              "generic name": medicine.name,
            },
          );
          _medicine[localListIndex].name = medicine.name;
        }

        if (value["desc"] != medicine.desc) {
          _medicineSubCollectionRef.doc(medicine.id).update(
            {
              "desc": medicine.desc,
            },
          );
          _medicine[localListIndex].desc = medicine.desc;
        }

        if (value["inStock"] != medicine.inStock) {
          _medicineSubCollectionRef.doc(medicine.id).update({
            "inStock": medicine.inStock,
          });
          _medicine[localListIndex].inStock = medicine.inStock;
        }
        if (value["brandList"] != medicine.brandList) {
          _medicineSubCollectionRef
              .doc(medicine.id)
              .update({"brandList": brandList});
          _medicine[localListIndex].brandList = medicine.brandList;
        }
        if (value["brand names"] != medicine.brandNames) {
          Database.updateBrandNamesArry(
              medicine, removedBrandNames, operation, localListIndex);
        }

        Fluttertoast.showToast(msg: "Document updated successfully!");

        return "Success";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return "Error";
    }
  }

  static Future updateBrandNamesArry(Medicine medicine, List? removedBrandNames,
      List<bool> operation, int index) async {
    await _medicineSubCollectionRef
        .doc(medicine.id)
        .update({"brand names": medicine.brandNames});

    //Update local list
    if (operation[0] == true) {
      for (int i = 0; i < medicine.brandNames.length; i++) {
        if (!_medicine[index].brandNames.contains(medicine.brandNames[i])) {
          _medicine[index].brandNames.add(medicine.brandNames[i]);
        }
      }
    }

    //Update local list
    if (operation[1] == true) {
      for (int i = 0; i < removedBrandNames!.length; i++) {
        _medicine[index]
            .brandNames
            .removeWhere((item) => item == removedBrandNames[i]);
      }
    }
  }

  static Future createMedicineDoc({
    required Medicine medicine,
  }) async {
    List brandList = [];
    medicine.brandNames.forEach((brand) {
      brandList.add(brand['name']);
    });
    try {
      String docId = _medicineSubCollectionRef.doc().id;
      medicine.id = docId;
      await _medicineSubCollectionRef.doc(docId).set({
        "id": docId,
        "generic name": medicine.name,
        "inStock": medicine.inStock,
        "pharmacyId": _currPharmacy!.id,
        "brand names": FieldValue.arrayUnion(medicine.brandNames),
        "brandList": brandList,
        "desc": medicine.desc,
      });

      Fluttertoast.showToast(msg: "Medicine added successfully!");

      //Update local list
      _medicine.add(medicine);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      return "Error";
    }
  }
}
