import 'package:bss_mobile_premium/screens/Irsaliye_Kabul/barkod_etiket.dart';
import 'package:bss_mobile_premium/screens/Irsaliye_Kabul/irsaliye_kabul.dart';
import 'package:bss_mobile_premium/screens/Sayim/sayim.dart';
import 'package:bss_mobile_premium/screens/Stok_Kabul/stok_kabul.dart';
import 'package:bss_mobile_premium/theme/manager/theme_manager.dart';
import 'package:flutter/material.dart';

class BarkoGiris extends StatefulWidget {
  @override
  _BarkoGirisState createState() => _BarkoGirisState();
}

class _BarkoGirisState extends State<BarkoGiris> {
  int _selectedIndex = 0;

  List<Widget> _pages = [
    StokKabul(),
    IrsaliyeKabul(pageChoose: "İrsaliye"),
    IrsaliyeKabul(pageChoose: "Devir"),
    BarkodEtiket(-1)

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
      length: _pages.length,
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Theme.of(context).backgroundColor,
              child:  TabBar(
                indicatorColor: Colors.greenAccent,
                labelColor: Colors.greenAccent,
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
                tabs: [
                  // Tab(icon: Icon(Icons.document_scanner_outlined), text: 'BARKOD'),
                  Tab(icon:  Icon(Icons.document_scanner_outlined), text: 'BARKOD'),
                  Tab(icon: Icon(Icons.receipt_long), text: 'İRSALİYE'),
                  Tab(icon: Icon(Icons.loop), text: 'DEVİR'),
                  Tab(icon: Icon(Icons.print_outlined), text: 'YAZDIR'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: _pages,
          ),
        ),
      ),
    );
    //   Scaffold(
    //   bottomNavigationBar: PreferredSize(
    //     preferredSize: Size.fromHeight(56), // bottomNavigationBar'ın yüksekliği
    //     child: BottomNavigationBar(
    //       selectedItemColor: Colors.greenAccent,
    //       backgroundColor: Theme.of(context).backgroundColor,
    //       unselectedItemColor: Colors.white,
    //       selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),
    //       unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 17),
    //       items: const <BottomNavigationBarItem>[
    //         BottomNavigationBarItem(
    //           icon: Icon(Icons.document_scanner_outlined),
    //           label: 'Barkod Kabul',
    //         ),
    //         BottomNavigationBarItem(
    //           icon: Icon(Icons.receipt_long),
    //           label: 'İrsaliye Kabul',
    //         ),
    //       ],
    //       currentIndex: _selectedIndex,
    //       onTap: _onItemTapped,
    //     ),
    //   ),
    //
    //   body: _pages[_selectedIndex],
    // );
  }
}