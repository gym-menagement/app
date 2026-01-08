# Gym Spring API Response Examples

이 문서는 Gym Spring Backend API의 응답 형식 예시를 제공합니다.

## 목차

- [인증 (Authentication)](#인증-authentication)
- [사용자 (User)](#사용자-user)
- [체육관 (Gym)](#체육관-gym)
- [멤버십 (Membership)](#멤버십-membership)
- [건강/운동 (Health)](#건강운동-health)
- [출석 (Attendance)](#출석-attendance)
- [결제 (Payment & Order)](#결제-payment--order)
- [PT 예약 (PT Reservation)](#pt-예약-pt-reservation)
- [공지사항 (Notice)](#공지사항-notice)
- [알람 (Alarm)](#알람-alarm)
- [QR 코드 (QR Code)](#qr-코드-qr-code)
- [공통 응답 패턴](#공통-응답-패턴)

---

## 인증 (Authentication)

### 1. 로그인 - GET /api/jwt

**Request:**

```
GET /api/jwt?loginid=testuser&passwd=password123
```

**Success Response (200):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "user": {
    "id": 1,
    "loginid": "testuser",
    "passwd": "$2a$10$encoded_password_hash",
    "email": "test@example.com",
    "name": "홍길동",
    "tel": "010-1234-5678",
    "address": "서울시 강남구",
    "image": "https://example.com/profile.jpg",
    "sex": 0,
    "birth": "1990-01-01 00:00:00",
    "type": 0,
    "connectid": "",
    "level": 0,
    "role": 3,
    "use": 0,
    "logindate": "2025-12-26 10:00:00",
    "lastchangepasswddate": "2025-12-26 10:00:00",
    "date": "2025-12-26 10:00:00",
    "extra": {
      "level": "일반",
      "use": "사용",
      "type": "일반",
      "role": "회원",
      "sex": "남성"
    }
  }
}
```

**Error Response (401 - Unauthorized):**

```json
null
```

**Error Response (404 - Not Found):**

```json
null
```

### 2. 로그인 - POST /api/auth/login

**Request:**

```json
{
  "loginid": "testuser",
  "passwd": "password123"
}
```

**Success Response (200):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "user": {
    "id": 1,
    "loginid": "testuser",
    "email": "test@example.com",
    "name": "홍길동",
    "tel": "010-1234-5678",
    "address": "서울시 강남구",
    "image": "https://example.com/profile.jpg",
    "sex": 0,
    "birth": "1990-01-01 00:00:00",
    "type": 0,
    "connectid": "",
    "level": 0,
    "role": 3,
    "use": 0,
    "logindate": "2025-12-26 10:00:00",
    "lastchangepasswddate": "2025-12-26 10:00:00",
    "date": "2025-12-26 10:00:00",
    "extra": {
      "level": "일반",
      "use": "사용",
      "type": "일반",
      "role": "회원",
      "sex": "남성"
    }
  }
}
```

---

## 사용자 (User)

### 1. 사용자 목록 조회 (페이징) - GET /api/user

**Request:**

```
GET /api/user?page=0&pagesize=10
```

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "loginid": "testuser",
      "passwd": "$2a$10$encoded_password",
      "email": "test@example.com",
      "name": "홍길동",
      "tel": "010-1234-5678",
      "address": "서울시 강남구",
      "image": "https://example.com/profile.jpg",
      "sex": 0,
      "birth": "1990-01-01 00:00:00",
      "type": 0,
      "connectid": "",
      "level": 0,
      "role": 3,
      "use": 0,
      "logindate": "2025-12-26 10:00:00",
      "lastchangepasswddate": "2025-12-26 10:00:00",
      "date": "2025-12-26 10:00:00",
      "extra": {
        "level": "일반",
        "use": "사용",
        "type": "일반",
        "role": "회원",
        "sex": "남성"
      }
    },
    {
      "id": 2,
      "loginid": "testuser2",
      "passwd": "$2a$10$encoded_password",
      "email": "test2@example.com",
      "name": "김철수",
      "tel": "010-9876-5432",
      "address": "서울시 서초구",
      "image": "",
      "sex": 0,
      "birth": "1985-05-15 00:00:00",
      "type": 0,
      "connectid": "",
      "level": 1,
      "role": 3,
      "use": 0,
      "logindate": "2025-12-25 15:30:00",
      "lastchangepasswddate": "2025-12-25 15:30:00",
      "date": "2025-12-25 15:30:00",
      "extra": {
        "level": "VIP",
        "use": "사용",
        "type": "일반",
        "role": "회원",
        "sex": "남성"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 2,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 사용자 단건 조회 - GET /api/user/{id}

**Request:**

```
GET /api/user/1
```

**Success Response (200):**

```json
{
  "id": 1,
  "loginid": "testuser",
  "passwd": "$2a$10$encoded_password",
  "email": "test@example.com",
  "name": "홍길동",
  "tel": "010-1234-5678",
  "address": "서울시 강남구",
  "image": "https://example.com/profile.jpg",
  "sex": 0,
  "birth": "1990-01-01 00:00:00",
  "type": 0,
  "connectid": "",
  "level": 0,
  "role": 3,
  "use": 0,
  "logindate": "2025-12-26 10:00:00",
  "lastchangepasswddate": "2025-12-26 10:00:00",
  "date": "2025-12-26 10:00:00",
  "extra": {
    "level": "일반",
    "use": "사용",
    "type": "일반",
    "role": "회원",
    "sex": "남성"
  }
}
```

**Error Response (404):**

```
(빈 응답)
```

### 3. 사용자 검색 (로그인ID) - GET /api/user/search/loginid

**Request:**

```
GET /api/user/search/loginid?loginid=testuser
```

**Response (200):**

```json
[
  {
    "id": 1,
    "loginid": "testuser",
    "passwd": "$2a$10$encoded_password",
    "email": "test@example.com",
    "name": "홍길동",
    "tel": "010-1234-5678",
    "address": "서울시 강남구",
    "image": "https://example.com/profile.jpg",
    "sex": 0,
    "birth": "1990-01-01 00:00:00",
    "type": 0,
    "connectid": "",
    "level": 0,
    "role": 3,
    "use": 0,
    "logindate": "2025-12-26 10:00:00",
    "lastchangepasswddate": "2025-12-26 10:00:00",
    "date": "2025-12-26 10:00:00",
    "extra": {
      "level": "일반",
      "use": "사용",
      "type": "일반",
      "role": "회원",
      "sex": "남성"
    }
  }
]
```

### 4. 사용자 카운트 - GET /api/user/count

**Response (200):**

```json
{
  "count": 150
}
```

### 5. 사용자 생성 - POST /api/user

**Request:**

```json
{
  "loginid": "newuser",
  "passwd": "password123",
  "email": "newuser@example.com",
  "name": "이영희",
  "tel": "010-5555-6666",
  "address": "서울시 마포구",
  "image": "",
  "sex": "FEMALE",
  "birth": "1995-03-20T00:00:00",
  "type": "NORMAL",
  "connectid": "",
  "level": "NORMAL",
  "role": "MEMBER",
  "use": "USE"
}
```

**Success Response (200):**

```json
{
  "id": 3,
  "loginid": "newuser",
  "passwd": "$2a$10$newly_encoded_password",
  "email": "newuser@example.com",
  "name": "이영희",
  "tel": "010-5555-6666",
  "address": "서울시 마포구",
  "image": "",
  "sex": 1,
  "birth": "1995-03-20 00:00:00",
  "type": 0,
  "connectid": "",
  "level": 0,
  "role": 3,
  "use": 0,
  "logindate": "2025-12-26 11:00:00",
  "lastchangepasswddate": "2025-12-26 11:00:00",
  "date": "2025-12-26 11:00:00",
  "extra": {
    "level": "일반",
    "use": "사용",
    "type": "일반",
    "role": "회원",
    "sex": "여성"
  }
}
```

### 6. 사용자 수정 - PUT /api/user/{id}

**Request:**

```json
{
  "loginid": "testuser",
  "passwd": "newpassword123",
  "email": "updated@example.com",
  "name": "홍길동",
  "tel": "010-1234-9999",
  "address": "서울시 강남구 테헤란로",
  "image": "https://example.com/new_profile.jpg",
  "sex": "MALE",
  "birth": "1990-01-01T00:00:00",
  "type": "NORMAL",
  "connectid": "",
  "level": "VIP",
  "role": "MEMBER",
  "use": "USE"
}
```

**Success Response (200):**

```json
{
  "id": 1,
  "loginid": "testuser",
  "passwd": "$2a$10$new_encoded_password",
  "email": "updated@example.com",
  "name": "홍길동",
  "tel": "010-1234-9999",
  "address": "서울시 강남구 테헤란로",
  "image": "https://example.com/new_profile.jpg",
  "sex": 0,
  "birth": "1990-01-01 00:00:00",
  "type": 0,
  "connectid": "",
  "level": 1,
  "role": 3,
  "use": 0,
  "logindate": "2025-12-26 10:00:00",
  "lastchangepasswddate": "2025-12-26 11:30:00",
  "date": "2025-12-26 10:00:00",
  "extra": {
    "level": "VIP",
    "use": "사용",
    "type": "일반",
    "role": "회원",
    "sex": "남성"
  }
}
```

### 7. 사용자 부분 수정 - PATCH /api/user/{id}

**Request:**

```json
{
  "tel": "010-9999-8888",
  "address": "부산시 해운대구"
}
```

**Success Response (200):**

```json
{
  "id": 1,
  "loginid": "testuser",
  "passwd": "$2a$10$encoded_password",
  "email": "test@example.com",
  "name": "홍길동",
  "tel": "010-9999-8888",
  "address": "부산시 해운대구",
  "image": "https://example.com/profile.jpg",
  "sex": 0,
  "birth": "1990-01-01 00:00:00",
  "type": 0,
  "connectid": "",
  "level": 0,
  "role": 3,
  "use": 0,
  "logindate": "2025-12-26 10:00:00",
  "lastchangepasswddate": "2025-12-26 10:00:00",
  "date": "2025-12-26 10:00:00",
  "extra": {
    "level": "일반",
    "use": "사용",
    "type": "일반",
    "role": "회원",
    "sex": "남성"
  }
}
```

### 8. 사용자 삭제 - DELETE /api/user/{id}

**Response (200):**

```json
{
  "success": true
}
```

---

## 체육관 (Gym)

### 1. 체육관 목록 조회 - GET /api/gym

**Request:**

```
GET /api/gym?page=0&pagesize=10
```

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "name": "강남 피트니스",
      "address": "서울시 강남구 테헤란로 123",
      "tel": "02-1234-5678",
      "user": 2,
      "date": "2025-01-01 09:00:00",
      "extra": {}
    },
    {
      "id": 2,
      "name": "서초 헬스클럽",
      "address": "서울시 서초구 강남대로 456",
      "tel": "02-9876-5432",
      "user": 3,
      "date": "2025-01-15 10:00:00",
      "extra": {}
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 2,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 체육관 단건 조회 - GET /api/gym/{id}

**Response (200):**

```json
{
  "id": 1,
  "name": "강남 피트니스",
  "address": "서울시 강남구 테헤란로 123",
  "tel": "02-1234-5678",
  "user": 2,
  "date": "2025-01-01 09:00:00",
  "extra": {}
}
```

### 3. 체육관 검색 (이름) - GET /api/gym/search/name

**Request:**

```
GET /api/gym/search/name?name=강남 피트니스
```

**Response (200):**

```json
[
  {
    "id": 1,
    "name": "강남 피트니스",
    "address": "서울시 강남구 테헤란로 123",
    "tel": "02-1234-5678",
    "user": 2,
    "date": "2025-01-01 09:00:00",
    "extra": {}
  }
]
```

### 4. 체육관 생성 - POST /api/gym

**Request:**

```json
{
  "name": "신규 피트니스",
  "address": "서울시 마포구 상암동 789",
  "tel": "02-5555-6666",
  "user": 4,
  "date": "2025-12-26T12:00:00"
}
```

**Response (200):**

```json
{
  "id": 3,
  "name": "신규 피트니스",
  "address": "서울시 마포구 상암동 789",
  "tel": "02-5555-6666",
  "user": 4,
  "date": "2025-12-26 12:00:00",
  "extra": {}
}
```

---

## 멤버십 (Membership)

### 1. 멤버십 목록 조회 - GET /api/membership

**Request:**

```
GET /api/membership?page=0&pagesize=10&user=1
```

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "userId": 1,
      "gymId": 1,
      "healthId": 5,
      "orderId": 10,
      "startDate": "2025-12-01 00:00:00",
      "endDate": "2026-03-01 00:00:00",
      "remainingCount": 0,
      "totalCount": 0,
      "status": 0,
      "date": "2025-12-01 10:00:00",
      "extra": {
        "status": "활성"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 멤버십 단건 조회 - GET /api/membership/{id}

**Response (200):**

```json
{
  "id": 1,
  "userId": 1,
  "gymId": 1,
  "healthId": 5,
  "orderId": 10,
  "startDate": "2025-12-01 00:00:00",
  "endDate": "2026-03-01 00:00:00",
  "remainingCount": 0,
  "totalCount": 0,
  "status": 0,
  "date": "2025-12-01 10:00:00",
  "extra": {
    "status": "활성"
  }
}
```

### 3. 사용자별 멤버십 조회 - GET /api/membership/search/user

**Request:**

```
GET /api/membership/search/user?user=1
```

**Response (200):**

```json
[
  {
    "id": 1,
    "userId": 1,
    "gymId": 1,
    "healthId": 5,
    "orderId": 10,
    "startDate": "2025-12-01 00:00:00",
    "endDate": "2026-03-01 00:00:00",
    "remainingCount": 0,
    "totalCount": 0,
    "status": 0,
    "date": "2025-12-01 10:00:00",
    "extra": {
      "status": "활성"
    }
  }
]
```

---

## 건강/운동 (Health)

### 1. 운동 프로그램 목록 - GET /api/health

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "categoryId": 1,
      "gymId": 1,
      "name": "3개월 헬스 회원권",
      "description": "3개월 무제한 이용권",
      "price": 300000,
      "termId": 2,
      "count": 0,
      "status": 0,
      "date": "2025-01-01 09:00:00",
      "extra": {
        "status": "활성"
      }
    },
    {
      "id": 2,
      "categoryId": 2,
      "gymId": 1,
      "name": "PT 10회권",
      "description": "1:1 퍼스널 트레이닝 10회",
      "price": 500000,
      "termId": null,
      "count": 10,
      "status": 0,
      "date": "2025-01-01 09:00:00",
      "extra": {
        "status": "활성"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 2,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 운동 프로그램 단건 조회 - GET /api/health/{id}

**Response (200):**

```json
{
  "id": 1,
  "categoryId": 1,
  "gymId": 1,
  "name": "3개월 헬스 회원권",
  "description": "3개월 무제한 이용권",
  "price": 300000,
  "termId": 2,
  "count": 0,
  "status": 0,
  "date": "2025-01-01 09:00:00",
  "extra": {
    "status": "활성"
  }
}
```

### 3. 운동 카테고리 목록 - GET /api/healthcategory

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "name": "헬스",
      "description": "웨이트 트레이닝 및 유산소 운동",
      "date": "2025-01-01 00:00:00",
      "extra": {}
    },
    {
      "id": 2,
      "name": "PT",
      "description": "1:1 퍼스널 트레이닝",
      "date": "2025-01-01 00:00:00",
      "extra": {}
    },
    {
      "id": 3,
      "name": "요가",
      "description": "요가 및 필라테스",
      "date": "2025-01-01 00:00:00",
      "extra": {}
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 3,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

---

## 출석 (Attendance)

### 1. 출석 기록 조회 - GET /api/attendance

**Request:**

```
GET /api/attendance?page=0&pagesize=20&user=1
```

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "userId": 1,
      "gymId": 1,
      "membershipId": 1,
      "checkInTime": "2025-12-26 08:30:00",
      "checkOutTime": "2025-12-26 10:00:00",
      "date": "2025-12-26 08:30:00",
      "extra": {}
    },
    {
      "id": 2,
      "userId": 1,
      "gymId": 1,
      "membershipId": 1,
      "checkInTime": "2025-12-25 18:00:00",
      "checkOutTime": "2025-12-25 20:00:00",
      "date": "2025-12-25 18:00:00",
      "extra": {}
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 2,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 출석 체크 - POST /api/attendance

**Request:**

```json
{
  "userId": 1,
  "gymId": 1,
  "membershipId": 1,
  "checkInTime": "2025-12-26T08:30:00",
  "checkOutTime": null,
  "date": "2025-12-26T08:30:00"
}
```

**Response (200):**

```json
{
  "id": 3,
  "userId": 1,
  "gymId": 1,
  "membershipId": 1,
  "checkInTime": "2025-12-26 08:30:00",
  "checkOutTime": "",
  "date": "2025-12-26 08:30:00",
  "extra": {}
}
```

---

## 결제 (Payment & Order)

### 1. 주문 목록 조회 - GET /api/order

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "userId": 1,
      "gymId": 1,
      "healthId": 1,
      "totalPrice": 300000,
      "discountId": null,
      "finalPrice": 300000,
      "status": 1,
      "date": "2025-12-01 10:00:00",
      "extra": {
        "status": "완료"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 주문 생성 - POST /api/order

**Request:**

```json
{
  "userId": 1,
  "gymId": 1,
  "healthId": 1,
  "totalPrice": 300000,
  "discountId": null,
  "finalPrice": 300000,
  "status": "PENDING",
  "date": "2025-12-26T12:00:00"
}
```

**Response (200):**

```json
{
  "id": 2,
  "userId": 1,
  "gymId": 1,
  "healthId": 1,
  "totalPrice": 300000,
  "discountId": null,
  "finalPrice": 300000,
  "status": 0,
  "date": "2025-12-26 12:00:00",
  "extra": {
    "status": "대기"
  }
}
```

### 3. 결제 목록 조회 - GET /api/payment

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "orderId": 1,
      "userId": 1,
      "paymentTypeId": 1,
      "paymentFormId": 1,
      "amount": 300000,
      "status": 1,
      "transactionId": "TXN20251201100000",
      "date": "2025-12-01 10:05:00",
      "extra": {
        "status": "완료"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 4. 결제 생성 - POST /api/payment

**Request:**

```json
{
  "orderId": 2,
  "userId": 1,
  "paymentTypeId": 1,
  "paymentFormId": 1,
  "amount": 300000,
  "status": "SUCCESS",
  "transactionId": "TXN20251226120000",
  "date": "2025-12-26T12:05:00"
}
```

**Response (200):**

```json
{
  "id": 2,
  "orderId": 2,
  "userId": 1,
  "paymentTypeId": 1,
  "paymentFormId": 1,
  "amount": 300000,
  "status": 1,
  "transactionId": "TXN20251226120000",
  "date": "2025-12-26 12:05:00",
  "extra": {
    "status": "완료"
  }
}
```

---

## PT 예약 (PT Reservation)

### 1. PT 예약 목록 - GET /api/ptreservation

**Request:**

```
GET /api/ptreservation?page=0&pagesize=10&user=1
```

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "userId": 1,
      "trainerId": 5,
      "gymId": 1,
      "membershipId": 1,
      "reservationDate": "2025-12-27 14:00:00",
      "duration": 60,
      "status": 0,
      "note": "첫 PT 세션",
      "date": "2025-12-26 09:00:00",
      "extra": {
        "status": "예약됨"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 1,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. PT 예약 생성 - POST /api/ptreservation

**Request:**

```json
{
  "userId": 1,
  "trainerId": 5,
  "gymId": 1,
  "membershipId": 1,
  "reservationDate": "2025-12-28T15:00:00",
  "duration": 60,
  "status": "PENDING",
  "note": "",
  "date": "2025-12-26T13:00:00"
}
```

**Response (200):**

```json
{
  "id": 2,
  "userId": 1,
  "trainerId": 5,
  "gymId": 1,
  "membershipId": 1,
  "reservationDate": "2025-12-28 15:00:00",
  "duration": 60,
  "status": 0,
  "note": "",
  "date": "2025-12-26 13:00:00",
  "extra": {
    "status": "예약됨"
  }
}
```

---

## 공지사항 (Notice)

### 1. 공지사항 목록 - GET /api/notice

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "gymId": null,
      "title": "시스템 점검 안내",
      "content": "12월 30일 새벽 2시-4시 시스템 점검이 있습니다.",
      "target": 0,
      "important": true,
      "startDate": "2025-12-26 00:00:00",
      "endDate": "2025-12-31 23:59:59",
      "date": "2025-12-26 09:00:00",
      "extra": {
        "target": "전체",
        "important": "중요"
      }
    },
    {
      "id": 2,
      "gymId": 1,
      "title": "연말 특별 할인 이벤트",
      "content": "12월 한정 신규 회원 30% 할인",
      "target": 1,
      "important": false,
      "startDate": "2025-12-20 00:00:00",
      "endDate": "2025-12-31 23:59:59",
      "date": "2025-12-20 10:00:00",
      "extra": {
        "target": "체육관별",
        "important": "일반"
      }
    }
  ],
  "page": 0,
  "size": 10,
  "totalElements": 2,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 공지사항 단건 조회 - GET /api/notice/{id}

**Response (200):**

```json
{
  "id": 1,
  "gymId": null,
  "title": "시스템 점검 안내",
  "content": "12월 30일 새벽 2시-4시 시스템 점검이 있습니다.",
  "target": 0,
  "important": true,
  "startDate": "2025-12-26 00:00:00",
  "endDate": "2025-12-31 23:59:59",
  "date": "2025-12-26 09:00:00",
  "extra": {
    "target": "전체",
    "important": "중요"
  }
}
```

---

## 알람 (Alarm)

### 1. 알람 목록 - GET /api/alarm

**Request:**

```
GET /api/alarm?page=0&pagesize=20&user=1
```

**Response (200):**

```json
{
  "content": [
    {
      "id": 1,
      "userId": 1,
      "type": 0,
      "title": "PT 예약 확정",
      "message": "12월 27일 14시 PT 예약이 확정되었습니다.",
      "isRead": false,
      "link": "/pt/reservation/1",
      "date": "2025-12-26 09:30:00",
      "extra": {
        "type": "시스템",
        "isRead": "읽지 않음"
      }
    },
    {
      "id": 2,
      "userId": 1,
      "type": 2,
      "title": "멤버십 만료 임박",
      "message": "멤버십이 3일 후 만료됩니다.",
      "isRead": true,
      "link": "/membership/1",
      "date": "2025-12-23 10:00:00",
      "extra": {
        "type": "경고",
        "isRead": "읽음"
      }
    }
  ],
  "page": 0,
  "size": 20,
  "totalElements": 2,
  "totalPages": 1,
  "first": true,
  "last": true,
  "empty": false
}
```

### 2. 알람 읽음 처리 - PATCH /api/alarm/{id}

**Request:**

```json
{
  "isRead": true
}
```

**Response (200):**

```json
{
  "id": 1,
  "userId": 1,
  "type": 0,
  "title": "PT 예약 확정",
  "message": "12월 27일 14시 PT 예약이 확정되었습니다.",
  "isRead": true,
  "link": "/pt/reservation/1",
  "date": "2025-12-26 09:30:00",
  "extra": {
    "type": "시스템",
    "isRead": "읽음"
  }
}
```

---

## QR 코드 (QR Code)

### 1. 회원 QR 코드 조회 - GET /api/memberqr/search/user

**Request:**

```
GET /api/memberqr/search/user?user=1
```

**Response (200):**

```json
[
  {
    "id": 1,
    "userId": 1,
    "qrCode": "QR_USER1_20251201_ABCD1234",
    "isActive": true,
    "expiryDate": "2026-12-01 00:00:00",
    "date": "2025-12-01 10:00:00",
    "extra": {
      "isActive": "활성"
    }
  }
]
```

### 2. QR 코드 검증 - GET /api/qrcode/validate

**Request:**

```
GET /api/qrcode/validate?code=QR_USER1_20251201_ABCD1234
```

**Success Response (200):**

```json
{
  "valid": true,
  "userId": 1,
  "userName": "홍길동",
  "gymId": 1,
  "membershipId": 1,
  "membershipStatus": "ACTIVE",
  "remainingDays": 90,
  "message": "유효한 QR 코드입니다."
}
```

**Invalid Response (200):**

```json
{
  "valid": false,
  "message": "유효하지 않거나 만료된 QR 코드입니다."
}
```

---

## 공통 응답 패턴

### 페이징 응답 구조

모든 목록 조회 API는 다음 구조를 따릅니다:

```json
{
  "content": [...],           // 실제 데이터 배열
  "page": 0,                  // 현재 페이지 (0부터 시작)
  "size": 10,                 // 페이지 크기
  "totalElements": 100,       // 전체 데이터 개수
  "totalPages": 10,           // 전체 페이지 수
  "first": true,              // 첫 페이지 여부
  "last": false,              // 마지막 페이지 여부
  "empty": false              // 데이터 없음 여부
}
```

### 에러 응답

대부분의 에러는 HTTP 상태 코드로 표현되며, 응답 본문은 비어있거나 null입니다:

- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `404 Not Found`: 리소스 없음
- `500 Internal Server Error`: 서버 에러

### Enum 값 매핑

#### Sex (성별)

- `0`: 남성 (MALE)
- `1`: 여성 (FEMALE)

#### Type (사용자 타입)

- `0`: 일반 (NORMAL)
- `1`: 소셜 (SOCIAL)

#### Role (역할)

- `0`: 관리자 (ADMIN)
- `1`: 매니저 (MANAGER)
- `2`: 트레이너 (TRAINER)
- `3`: 회원 (MEMBER)
- `4`: 게스트 (GUEST)

#### Level (레벨)

- `0`: 일반 (NORMAL)
- `1`: VIP
- `2`: VVIP

#### Use (사용 여부)

- `0`: 사용 (USE)
- `1`: 미사용 (UNUSE)

#### Status (상태)

- `0`: 대기 (PENDING)
- `1`: 완료 (COMPLETED)
- `2`: 취소 (CANCELLED)
- `3`: 만료 (EXPIRED)

### Extra 필드

대부분의 응답에는 `extra` 필드가 포함되어 있으며, enum 값의 한글 표현을 제공합니다:

```json
"extra": {
  "status": "활성",
  "role": "회원",
  "level": "일반"
}
```

### 날짜 형식

모든 날짜는 `YYYY-MM-DD HH:mm:ss` 형식의 문자열로 반환됩니다:

```
"2025-12-26 10:00:00"
```

### 인증 헤더

JWT 토큰이 필요한 요청에는 다음 헤더를 포함해야 합니다:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 추가 엔티티 API 패턴

위에서 설명한 엔티티 외에도 다음 엔티티들이 동일한 패턴을 따릅니다:

- **Discount** (`/api/discount`)
- **PaymentType** (`/api/paymenttype`)
- **PaymentForm** (`/api/paymentform`)
- **Term** (`/api/term`)
- **DayType** (`/api/daytype`)
- **Inquiry** (`/api/inquiry`)
- **Setting** (`/api/setting`)
- **SystemLog** (`/api/systemlog`)
- **LoginLog** (`/api/loginlog`)
- **IpBlock** (`/api/ipblock`)
- **Stop** (`/api/stop`)
- **Token** (`/api/token`)
- **WorkoutLog** (`/api/workoutlog`)
- **TrainerMember** (`/api/trainermember`)
- **GymTrainer** (`/api/gymtrainer`)
- **MemberBody** (`/api/memberbody`)
- **UseHealth** (`/api/usehealth`)
- **UseHealthUsage** (`/api/usehealthusage`)
- **PushToken** (`/api/pushtoken`)
- **AppVersion** (`/api/appversion`)

모든 API는 다음 표준 엔드포인트를 제공합니다:

- `GET /api/{entity}` - 페이징 목록
- `GET /api/{entity}/{id}` - 단건 조회
- `GET /api/{entity}/search/{field}?{field}=value` - 필드별 검색
- `GET /api/{entity}/count` - 개수 조회
- `POST /api/{entity}` - 생성
- `POST /api/{entity}/batch` - 일괄 생성
- `PUT /api/{entity}/{id}` - 전체 수정
- `PATCH /api/{entity}/{id}` - 부분 수정
- `DELETE /api/{entity}/{id}` - 삭제
- `DELETE /api/{entity}/batch` - 일괄 삭제
