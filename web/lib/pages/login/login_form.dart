import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sds_web/model/model.dart';

class LoginForm extends StatelessWidget {
  final Widget? child1;
  final Widget? child2;
  const LoginForm({super.key, this.child1, this.child2});
  @override
  Widget build(BuildContext context) {
    final model = context.read<Model>();
    return Center(
      child: Container(
        width: 1000,
        height: 600,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        model.getApiImgUri('/login/chef.png'),
                        width: 65,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Стоматологический софт',
                            style: TextStyle(
                              color: Color(0xff002C52),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Профессора Шастина',
                            style: TextStyle(
                              color: Color(0xff002C52),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Shastin Dental Software v 2.0',
                            style: TextStyle(
                              color: Color(0xff8EAFB8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(child: child1 ?? const SizedBox()),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: DecorationImage(
                    image: NetworkImage(
                        model.getApiImgUri('/login/imageLogin.png')),
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: child2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
