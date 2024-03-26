package com.yuanxiaocai.androidproguard.bean;

/**
 * 用户信息类，用于存储用户的姓名和年龄
 *
 * @author 猿小蔡
 * @since 2024/3/27
 */
public class User {

    private String name; // 用户姓名

    private int age; // 用户年龄

    /**
     * 获取用户姓名
     *
     * @return 用户姓名
     */
    public String getName() {
        return name;
    }

    /**
     * 设置用户姓名
     *
     * @param name 用户姓名
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * 获取用户年龄
     *
     * @return 用户年龄
     */
    public int getAge() {
        return age;
    }

    /**
     * 设置用户年龄
     *
     * @param age 用户年龄
     */
    public void setAge(int age) {
        this.age = age;
    }

}
